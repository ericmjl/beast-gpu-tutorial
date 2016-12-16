pandoc index.md -o index.html -H header.html --toc -c styling.css
pandoc cli.md -o cli.html -H header --toc -c styling.css

git add .
git commit
git push
