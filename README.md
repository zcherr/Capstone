# FPO_capstone
Repository for DSHB-2023-Cohort FPO Capstone Project.

# Steps & Tips
## 2024-08-02
- After first cloning of the repo, each time before modifying the files locally, **remember to `git pull` in the shell to update to current repo**. But you could also do `git checkout/log` to see the overview of changes before pulling.
- It is recomended to create everyone's own working script on the basis of the existing ones and modified in the individual files at present, for the sake of conflict prevention. Under this circumstances, we could clone from the main branch and push to main directly.
- Could do `source(<.R file name>)` in R/Rmarkdown scripts to use the functions directly.
- Switch/create new cache folder/file names, so that it would not override the existing ones! (In the formal implementation)
- If you're using Mac, it's better to remove the `.DS_Store` before pushing to the origin. Or it's easy to cause version conflict when multiple users are uploading this file. Use `git status` to check out the correct files you wanna push each time!

## A demo pipe line of using the repo
- `git clone <repo>`
- `git pull` # for updating from the latest repo
- <work \on your scripts>
- `git status` # check with files need to be pushed
- `git add <filename>` or `git add .` (if all files are desired)
- `git commit -m "<Comment \on this push. Better be concise and informative>"
- `git push origin main` or `git push` (if working on the main branch)
