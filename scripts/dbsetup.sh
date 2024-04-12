npm run build:result
rm -rf ~/projects/team-colab/server/src/static
rm -rf ~/projects/team-colab/server/src/templates

cp -r ~/projects/team-colab/client/result/static ~/projects/team-colab/server/src
cp -r ~/projects/team-colab/client/result/templates ~/projects/team-colab/server/src
