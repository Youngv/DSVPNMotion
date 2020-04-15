set -x

brew install imagemagick

pushd resources/Assets.xcassets/AppIcon.appiconset/

for size in 512 256 128 32 16
do
  cp "1024x1024.png" "Icon_${size}x${size}.png"
  mogrify -resize "$((size))x$((size))" "Icon_${size}x${size}.png"

  cp "1024x1024.png" "Icon_${size}x${size}@2x.png"
  mogrify -resize "$((size*2))x$((size*2))" "Icon_${size}x${size}@2x.png"
done

popd