pandoc index.md -o index.html -H header.html --toc -c styling.css -s

pandoc cli.md -o cli.html -H header.html --toc -c styling.css -s

pandoc beast2.md -o beast2.html -H header.html --toc -c styling.css -s

git add .
git commit
git push
