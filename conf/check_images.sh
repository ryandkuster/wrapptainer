#!/usr/bin/env bash


check_newer_quay() {
    #image_url="docker://quay.io/biocontainers/bcftools:1.23--h3a4d415_0"

    repo=$(echo $image_url | sed -n 's|docker://quay.io/\([^:]*\):.*|\1|p')
    current_version=$(echo $image_url | sed -n 's|.*:\([^-]*\)--.*|\1|p')
    api_url="https://quay.io/api/v1/repository/$repo/tag/"
    tags=$(curl -s "$api_url" | jq -r '.tags[].name' 2>/dev/null)
    
    #echo $tags
    echo -e "\nCurrent version :\n${current_version}"
    echo -e "\n10 most recent versions:\n"
    echo "$tags" | grep --color=always -E "^|${current_version}" | head
}

check_newer_docker() {
    #image_url="docker://broadinstitute/gatk:latest"

    repo=$(echo $image_url | sed -n 's|docker://\([^:]*\):.*|\1|p')
    current_version=$(echo $image_url | sed -n 's|.*:\(.*\)|\1|p')
    api_url="https://hub.docker.com/v2/repositories/$repo/tags/"
    tags=$(curl -s "$api_url?page_size=100" | jq -r '.results[].name' 2>/dev/null)
    
    #echo $tags
    echo -e "\nCurrent version :\n${current_version}"
    echo -e "\n10 most recent versions:\n"
    echo "$tags" | grep --color=always -E "^|${current_version}" | head
}

#=============================================================================
# Iterate images
#=============================================================================
for image_url in $( cut -d "=" -f 2 ./images.conf ); do
    image_url=$( echo $image_url | sed 's/"//g' )
    echo -e "\n============================================================================="
    echo $image_url
    echo -e "============================================================================="
    if [[ "$image_url" == *"quay"* ]]; then
        check_newer_quay
    else
        check_newer_docker
    fi
    sleep 1
done

