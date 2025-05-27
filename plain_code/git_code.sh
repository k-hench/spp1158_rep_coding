# --- setting up a git repository ---
# create empty new folder - no git yet
mkdir project_folder
cd project_folder
ls -a
# turn normal folder into git repo
git init
ls -a
# checking git status (confirming folder is a repo)
git status
# --- start changing folder conten ---
# creating new file, checking git monitoring
echo "AAA" > A.txt
git status
# staging file "A.txt" for commt (select it to log changes)
git add A.txt
git status
# commit the changes to the staged files (actually log the changes)
git commit -m "added A"
# add more edits to existing file and create additional new file
echo "aaa" >> A.txt
echo "BBB" > B.txt
# stage and commit ALL files with changes
git add .
git commit -m "added B"
# anticipate a file that should not be tracked in version control ("C.txt")
echo "C.txt" > .gitignore
# edit existing file and create "private" file
echo "bbb" >> B.txt
echo "CCC" > C.txt
# the ignored file should not show up in the git records
git status
git add .
git commit -m "expanded B"
# --- start time travels ----
# overview of past commits
git log --pretty=oneline
# list all files in project folder
tree
# check content of A.txt
cat A.txt
# restore the project state at the time point of the first commit
git checkout ':/added A'
tree
# re-check content of A.txt
cat A.txt
# return to the most recent project state
git checkout main
# display the tracked changes between the 1.& 2. commit
git diff ':/added A' ':/added B'
# --- using multiple branches ----
# create a new branch called "test"
git branch test
# switch to the new test branch
git checkout test
# just checking
git status
# edtit file "A.txt" on test branch, stage and commit
echo "111" >> A.txt
git add .
git commit -m "expanded A"
# switch back to the main branch
git checkout main
cat A.txt
# integrate the changes from the test branch
git merge test
cat A.txt
# now, do some additions to "B.txt" on the main branch, stage and commit
echo "bbb" >> B.txt
git add .
git commit -m "more B edits"
# switch back to test branch
git checkout test
# also modify "B.txt" on the test branch (and stage and commit)
echo "222" >> B.txt
git add .
git commit -m "test B edits"
# going back to the main branch and trying to integrate the edits from "test"
git checkout main
git merge test
# checking the conflicting file
cat B.txt
# the conflicting file after resolving the confilct
cat B.txt
# the resolved conflict needs to be staged and commited to complete the process
git add .
git commit -m "resolved conflict"
# --- connecting to a remote (using github) ---
# adding a url as a "remote" to setup a online address for synchronizing (github)
git remote add origin https://github.com/<usr_name>/project_folder.git
# send edits from the local machine to the online version (the remote)
git push -u origin main
# receive edits from the remote and integrate them into the loacl repository
git pull origin main
# download an existing git repositroy (including it's entire version controlled history)
git clone https://github.com/<usr_name>/project_folder.git