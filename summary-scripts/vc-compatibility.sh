#!/usr/bin/env bash
set -eo pipefail

generate_summary() {
  declare -A result
  declare -A seen_bn
  declare -A seen_vc

  # Normalize a client name (capitalize first letter)
  normalize() {
    echo "$1" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}'
  }

  # Loop through all pair entries
  while read -r item; do
    index=$(echo "$item" | jq -r '.index')
    pair_string=$(echo "$item" | jq -r '.pairs')

    # Check if summary exists and was successful
    summary_path="./summaries/summary-vc-compatibility-$index/summary.json"
    if [[ -f "$summary_path" ]]; then
      test_result=$(jq -r '.test_result' "$summary_path")
    else
      test_result="missing"
    fi

    IFS=',' read -ra pairs <<< "$pair_string"
    if [[ "$test_result" == "success" || "$test_result" == "failed" ]]; then
      for pair in "${pairs[@]}"; do
        if [[ "$pair" == */* ]]; then
          bn_raw=$(echo "$pair" | cut -d'/' -f1)
          vc_raw=$(echo "$pair" | cut -d'/' -f2 | cut -d'-' -f1)
        else
          bn_raw=$(echo "$pair" | cut -d'-' -f1)
          vc_raw="$bn_raw"
        fi

        bn=$(normalize "$bn_raw")
        vc=$(normalize "$vc_raw")

        seen_bn["$bn"]=1
        seen_vc["$vc"]=1
        result["$bn,$vc"]="✅"
      done
    fi
    
    if [[ "$test_result" == "failed" ]]; then
      # Parse failed client pairs from failed_test_status
      if [[ -f "$summary_path" ]]; then
        failed_lines=$(jq -r '.failed_test_status' "$summary_path" | grep 'check_consensus_block_proposals' | grep 'failed')

        while read -r line; do
          # Extract from "Wait for block proposal from X-<el>-<bn>[-<vc>]"
          client_part=$(echo "$line" | grep -oE '[0-9]+-[a-z0-9-]+-[a-z0-9-]+$' | cut -d'-' -f2-)

          # Split out bn and optional vc
          IFS='-' read -ra parts <<< "$client_part"
          bn_raw="${parts[0]}"
          vc_raw="${parts[1]:-${parts[0]}}"  # fallback to bn if vc not specified

          bn=$(normalize "$bn_raw")
          vc=$(normalize "$vc_raw")

          seen_bn["$bn"]=1
          seen_vc["$vc"]=1
          result["$bn,$vc"]="❌"
        done <<< "$failed_lines"
      fi
    fi
  done < <(echo "$pairs" | jq -c '.[]')

  # Collect sorted BNs and VCs
  bns=($(printf "%s\n" "${!seen_bn[@]}" | sort))
  vcs=($(printf "%s\n" "${!seen_vc[@]}" | sort))

  # Initialize missing pairs as ❌
  for bn in "${bns[@]}"; do
    for vc in "${vcs[@]}"; do
      result["$bn,$vc"]="${result["$bn,$vc"]:-❌}"
    done
  done

  # Generate markdown summary
  header="|               |"
  for vc in "${vcs[@]}"; do
    header+=" ${vc} VC |"
  done

  separator="|---------------|"
  for _ in "${vcs[@]}"; do
    separator+="-------------|"
  done

  rows=""
  for bn in "${bns[@]}"; do
    row="| ${bn} BN"
    for vc in "${vcs[@]}"; do
      row+=" | ${result["$bn,$vc"]}"
    done
    row+=" |"
    rows+="${row}"$'\n'
  done

  # Output to GitHub Actions summary
  {
    echo "$header"
    echo "$separator"
    echo "$rows"
  } >> "$GITHUB_STEP_SUMMARY"

}
