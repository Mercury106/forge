rm app/assets/javascripts/turbojs/turbo.js
rm public/assets/turbojs/turbo.js
curl forge.dev/assets/turbojs/turbo.js > app/assets/javascripts/turbojs/turbo.js
mkdir -p public/assets/turbojs/
cp app/assets/javascripts/turbojs/turbo.js public/assets/turbojs/turbo.js