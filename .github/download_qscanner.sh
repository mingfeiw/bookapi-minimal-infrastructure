#!/bin/bash
######################################################################################################################################
# @name         : download_qscanner.sh
#
# @description  : This script is provided to allow you to download appropriate QScanner binary on your machine. It will
#                 determine the OS and machine's architecture and download the corresponding QScanner binary. It will also
#                 perform SHA256 checksum validation of the binary. 
#
#                 For more details, run "download_qscanner.sh -h"
#
######################################################################################################################################

function print_usage () {
    echo "Usage:"
    echo "------"
    echo " -h                       : Show help."
    echo " -a                       : Download binaries for all supported machines."
    echo " -c                       : Skip checksum validation."
    echo " -k <key_file>            : Use the given key file to verify binary signature."
    echo ""
}


# --------------------------------------------------------------------------------------------------
# Download binary from given URL
# $1 : Binary URL
# $2 : Destination path where artifacts will be downloaded
# --------------------------------------------------------------------------------------------------
function downloadBinary () {
    BINARY_URL=$1
    DESTINATION_PATH=$2

    ARTIFACT_NAME=$(basename $BINARY_URL)
    VERSION=$(echo $ARTIFACT_NAME | cut -d - -f 2)
    OS=$(echo $ARTIFACT_NAME | cut -d . -f 4 | cut -d - -f 1)
    ARCH=$(echo $ARTIFACT_NAME | cut -d . -f 4 | cut -d - -f 2)

    echo "QScanner version    : $VERSION"
    echo "Target OS           : $OS"
    echo "Target architecture : $ARCH"
    echo ""

    # Validate the download URL first
    echo -n "Validating URL ..."
    RESPONSE_CODE=$(curl -skIL -o /dev/null -w "%{http_code}" $BINARY_URL)
    if [ $RESPONSE_CODE -ne 200 ];then
        echo " [ERROR] Failed to download $BINARY_URL. Response code: $RESPONSE_CODE"
        exit 1
    fi
    echo " [OK]"
    
    echo -n "Downloading $BINARY_URL ..."
    curl -kOsL $BINARY_URL
    DOWNLOAD_ERR=$?
    if [ $DOWNLOAD_ERR -ne 0 ]; then
        echo " [ERROR] Failed to download $BINARY_NAME binary. Exit code: $DOWNLOAD_ERR"
        exit $DOWNLOAD_ERR
    fi
    echo " [OK]"
    
    echo -n "Extracting ..."
    EXTRACTED_PATH=/tmp/qscanner_extracted
    mkdir -p $EXTRACTED_PATH
    tar -xzf $ARTIFACT_NAME -C $EXTRACTED_PATH 
    EXTRACTION_ERR=$?
    if [ $EXTRACTION_ERR -ne 0 ]; then
        echo " [ERROR] Artifact appears to be corrupted. Extraction failed: $EXTRACTION_ERR"
        exit $EXTRACTION_ERR
    fi
    echo " [OK]"
    
    # --------------------------------------------------------------------------------------------------
    # Checksum validation
    # --------------------------------------------------------------------------------------------------
    CHECKSUM_FILE="$BINARY_NAME.sha256"
    SIGNATURE_FILE="${BINARY_NAME}.signature"
    SHA_COMMAND="sha256sum"
    
    if [ "$DO_CHECKSUM_VALIDATION" = true ] && [ "$OS" != "darwin" ] ; then
        echo -n "Validating checksum ..."
    
        if [ ! -f $EXTRACTED_PATH/$CHECKSUM_FILE ]; then
            echo "Checksum file not found. Exiting"
            cleanup
            exit 1
        fi
        echo " [OK]"
    
        EXPECTED_CHECKSUM=$(cat $EXTRACTED_PATH/$CHECKSUM_FILE)
        ACTUAL_CHECKSUM=$($SHA_COMMAND $EXTRACTED_PATH/$BINARY_NAME | awk '{print $1}')
        if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM"  ]; then
            echo " [ERROR] Checksum validation failed"
            cleanup
            exit 1
        fi
    else
        echo "Skipping Checksum validation"
    fi
    
    # --------------------------------------------------------------------------------------------------
    # Signature verification
    # --------------------------------------------------------------------------------------------------
    if [ "$KEY_FILE" != "" ] && [ "$OS" != "darwin" ]; then
        echo -n "Verifying binary signature ..."
    
        if [  -f $EXTRACTED_PATH/$SIGNATURE_FILE ]; then
            SIGN256FILE=$EXTRACTED_PATH/sign.sha256
            openssl base64 -d -in $EXTRACTED_PATH/$SIGNATURE_FILE -out $SIGN256FILE
            openssl dgst -sha256 -verify $KEY_FILE -signature $SIGN256FILE $EXTRACTED_PATH/$BINARY_NAME
            if [ $? -ne 0 ]; then
                echo " [WARNING] Signature verification failed. Did you use a valid key file? Be careful while running executables with invalid signature!"
            else
                echo " [OK]"
            fi
        else
            echo " [ERROR] Signature file not found. Skipping signature verification."
        fi
    
    fi
    
    # --------------------------------------------------------------------------------------------------
    # Move artifacts to destination path
    # --------------------------------------------------------------------------------------------------
    mkdir -p $DESTINATION_PATH
    mv $EXTRACTED_PATH/$BINARY_NAME $DESTINATION_PATH/
    mv $EXTRACTED_PATH/$CHECKSUM_FILE $DESTINATION_PATH/
    if [ "$OS" != "darwin" ]; then
        mv $EXTRACTED_PATH/$SIGNATURE_FILE $DESTINATION_PATH/
    fi
    cleanup
    
    echo ""
    echo "SUCCESS: Downloaded at $DESTINATION_PATH/$BINARY_NAME"
    echo ""
}

# --------------------------------------------------------------------------------------------------
function cleanup () {
    if [ -d $EXTRACTED_PATH ]; then
        rm -rf $EXTRACTED_PATH
    fi

    if [ -f $ARTIFACT_NAME ]; then
        rm -rf $ARTIFACT_NAME
    fi
}

# Keys for supported OS-ARCH combos
ARTIFACT_KEYS=("linux-amd64" "linux-arm64" "darwin-amd64" "darwin-arm64" "windows-amd64" "windows-arm64")

# Function to return download URL for a given key
get_artifact_value() {
    case "$1" in
        linux-amd64) echo https://cask.qg1.apps.qualys.com/cs/p/MwmsS_SfM0RTBIc5r-hpCUmY34xkB4n93rJNAfOf_BH5BnExjNT7P-48_03RUMr_/n/qualysincgov/b/us01-cask-artifacts/o/cs/qscanner/4.6.0-4/qscanner-4.6.0-4.linux-amd64.tar.gz;;
        linux-arm64) echo https://cask.qg1.apps.qualys.com/cs/p/T1IGQtz-b1sgMRlRD6i3CN95qDE9d_YbSn4qYj8UdYV4EFvd9bMovNrwfKs171a_/n/qualysincgov/b/us01-cask-artifacts/o/cs/qscanner/4.6.0-4/qscanner-4.6.0-4.linux-arm64.tar.gz;;
        darwin-amd64) echo https://cask.qg1.apps.qualys.com/cs/p/vvzUEJ7gjf6uqdVB0qKPDhqbLwMe_OjRHEsLyPdtvsiPK6uNcgEBKVAif4W9oeHi/n/qualysincgov/b/us01-cask-artifacts/o/cs/qscanner/4.6.0-4/qscanner-4.6.0-4.darwin-amd64.tar.gz;;
        darwin-arm64) echo  ;;
        windows-amd64) echo  ;;
        windows-arm64) echo  ;;
        *) echo "" ;;
    esac
}


BINARY_NAME="qscanner"
DO_CHECKSUM_VALIDATION=true
DOWNLOAD_ALL=false
KEY_FILE=""

# --------------------------------------------------------------------------------------------------
# Process command line flags
# --------------------------------------------------------------------------------------------------
while getopts 'hack:' flag; do
  case "${flag}" in
    a) DOWNLOAD_ALL=true ;;
    c) DO_CHECKSUM_VALIDATION=false ;;
    k) KEY_FILE="${OPTARG}" ;;
    h) print_usage
       exit 0;;
    *) print_usage
       exit 1 ;;
  esac
done


# --------------------------------------------------------------------------------------------------
# Download all the supported binaries if option is provided
# --------------------------------------------------------------------------------------------------
if [ "$DOWNLOAD_ALL" = true ] ; then
    echo "Downloading $BINARY_NAME for all supported machines"
    echo ""

    for key in "${ARTIFACT_KEYS[@]}"; do
        BINARY_URL=$(get_artifact_value "$key")

        echo -n "Checking $key..."
        if [ -n "$BINARY_URL" ]; then
            echo " Downloading..."
            downloadBinary "$BINARY_URL" "$key"
        else
            echo "  [NOT SUPPORTED]"
            echo ""
        fi
    done
    exit 0
fi

# --------------------------------------------------------------------------------------------------
# Determine Host OS and Architecture
# --------------------------------------------------------------------------------------------------
OS=$(uname | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m | tr '[:upper:]' '[:lower:]')
if [ "$ARCH" == "x86_64" ] || [ "$ARCH" == "amd64" ]; then
    ARCH="amd64"
elif [ "$ARCH" == "aarch64" ] || [ "$ARCH" == "arm64" ]; then
    ARCH="arm64"
fi

# Fetch qscanner URL for this OS and ARCH from ARTIFACT_URL_MAP

BINARY_URL=$(get_artifact_value "$OS-$ARCH")

if [ "$BINARY_URL" == "" ];then
    echo "ERROR: Unsupported host envirnoment: $OS-$ARCH"
    exit 1
fi

downloadBinary $BINARY_URL $OS-$ARCH
