# this python script should be run from the root of the project (project_folder)
# python ./code/py/dd_explore.py
import session_info   # to capture the computing environment
import pandas as pd   # to help organize data
import seaborn as sns # for plotting

# apply the default plotting theme
sns.set_theme(style = "ticks", font_scale = 0.85, rc={'figure.figsize':(5,5)})

# load data from TSV file, first three lines are comments
data = pd.read_csv('data/dd_masked.tsv', delimiter = '\t')

# scatterplot of the data for a first inspection
g = sns.relplot(
    data = data,
    x = "x", y = "y", s = 2.5
)
# add title to the plot
g.fig.suptitle("mysterious data", fontsize=12)
# save plot to file
g.fig.savefig("results/out.png")

# Log session information
print("python packages used:\n---------------")
session_info.show()
print("---------------\n")
