# --- setting up the basic project structure ---
# create a skeleton of nested directories for a new project
mkdir -p project_folder/data
mkdir -p project_folder/code/R project_folder/code/py
mkdir -p project_folder/results
# navigte into the new folder and intiate version control
cd project_folder
git init
touch .gitignore
# create readme file for the project
echo -e "# My Study Name\n\n**Author:** Your Name\n\n" > readme.md
echo -e "Description of the project..." >> readme.md
# initiate Rstudio project
echo "Version: 1.0

RestoreWorkspace: No
SaveWorkspace: No
AlwaysSaveHistory: Default

EnableCodeIndexing: Yes
UseSpacesForTab: Yes
NumSpacesForTab: 2
Encoding: UTF-8

RnwWeave: Sweave
LaTeX: pdfLaTeX" > project_name.Rproj
# intial state of the project folder
tree
# commit the initial state of the project folder
git add .
git commit -m "project setup"
# downloading external data
cd data/
wget https://raw.githubusercontent.com/k-hench/repcoding_online_resources/refs/heads/main/data/dd_masked.tsv
cd ..
# copy python script into the project
cp ~/external_resources/scripts/py/dd_explore.py code/py/
# run python script
python code/py/dd_explore.py > results/python_env.log
# link external data into the project
cd data
ln -s ~/external_resources/data/dd_key.tsv ./
cd ..
# copy R script into the project
cp ~/external_resources/scripts/R/dd_resolve.R code/R/
# run R script from project_folder/code/R
Rscript code/R/dd_resolve.R 
# run R script from project_folder/
cd code/R
Rscript dd_resolve.R
cd ../../
# used renv package to capture the current R working environment
R --slave -e 'renv::init(force = TRUE)'
# cleanup - we only created these to make a point
rm plot_standard.pdf code/R/plot_standard.pdf
# prevent plots from being logged
echo "*.png" >> .gitignore
echo "*.pdf" >> .gitignore
# commit the latest updates to version control
git add .
git status
git commit -m "mystery solved"
# --- outlook ---
mkdir -p code/workflow
touch code/workflow/snakefile
mkdir -p code/workflow/rules
mkdir -p code/workflow/envs
# final folder overview
tree -L 3
