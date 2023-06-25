#! /bin/bash
libPath="${1:-}"
libRepository="${2:-}"
javaHomeSrcZipPath="${3:-}"

if [[ -z "$libPath" ]]; then
  echo "Please configure libPath"
  exit 1
fi

if [[ -z "$libRepository" ]]; then
  echo "Please configure libRepository"
  exit 1
fi

if [[ -z "$javaHomeSrcZipPath" ]]; then
  echo "Please configure java home src.zip path"
  exit 1
fi

rm -rf "$libPath"
mkdir -p "$libPath"

for file in $(find $libRepository -type f -name '*-sources.jar'); do
  tar -C $libPath -zvxf $file
done

unzip "$javaHomeSrcZipPath" -d "$libPath"
echo "Sync sources sucessfully"

cd $libPath && git init
