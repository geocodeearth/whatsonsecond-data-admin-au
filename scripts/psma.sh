#!/bin/bash
set -euo pipefail
. "$(dirname "$0")/utils.sh"

# source: https://data.gov.au/dataset/ds-dga-bdcf5b09-89bc-47ec-9281-6b8e9ee147aa/details?q=psma%20localities
PSMA_ZIP_URL='https://data.gov.au/data/dataset/bdcf5b09-89bc-47ec-9281-6b8e9ee147aa/resource/53c24b8e-4f55-4eed-a189-2fc0dcca6381/download/aug20_adminbounds_esrishapefileordbffile.zip'
PSMA_ZIP_FILENAME="${PSMA_ZIP_URL##*/}"
PSMA_ZIP_LOCAL_PATH="${DOWNLOADS_DIR}/${PSMA_ZIP_FILENAME}"

# download file
if [ -f "${PSMA_ZIP_LOCAL_PATH}" ]; then
  echo "file exists, skip downloading: ${PSMA_ZIP_FILENAME}"
else
  curl "${PSMA_ZIP_URL}" > "${PSMA_ZIP_LOCAL_PATH}"
fi

# decompress file
if [ -d "${DOWNLOADS_DIR}/psma" ]; then
  echo "dir exists, skip extracting: ${PSMA_ZIP_FILENAME}"
else
  mkdir -p "${DOWNLOADS_DIR}/psma"
  unzip "${PSMA_ZIP_LOCAL_PATH}" -d "${DOWNLOADS_DIR}/psma"
fi

# skip geojson for now
exit 0

# convert to geojson
IFS=$'\n'
for SHP_PATH in $(find "${DOWNLOADS_DIR}/psma" -type f -name '*.shp');
do
  PSMA_GEOJSON_GZ_FILENAME_LOCAL_PATH="${SHP_PATH%.*}.geojsonl.gz"
  if [ -f "${PSMA_GEOJSON_GZ_FILENAME_LOCAL_PATH}" ]; then
    echo "file exists, skip generating: ${PSMA_GEOJSON_GZ_FILENAME}"
  else
    ogr2ogr \
      -f 'GeoJSON' \
      -t_srs 'crs:84' \
      '/vsistdout/' \
      "${SHP_PATH}" \
        | pigz --best \
          > "${PSMA_GEOJSON_GZ_FILENAME_LOCAL_PATH}"
  fi
done
unset IFS
