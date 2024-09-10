# Flexible Navigation Task Behaviour Analysis

Pipeline for giving an overview of behavioural data from mice in the flexible navigation task.

## Package contents

### Main pipeline
For a list of Animal IDs:
* Creates intermediate variables summarising trial- and session-level information.
* Plots an overvie of behaviour across trials within each session, including accuracy, bias and number of aborted trials.
* Plots an overview of performance over sessions, annotated by the availability of ephys data (if it exists).

### Exploratory analysis
* Plots spatial bias (tendency to choose port 0 versus port 1 dependent on dot location).

## User guide

To run the code, you need to first install this Github repository locally, and then create an environment from the local repository.

### Installation

For easy installation, open git bash and navigate to the directory in which you would like to download this git repository with ```cd <directory_path>```. 

You can now locally clone this repository by entering the following into your terminal window:
```
git clone https://github.com/m-lockwood/FNT_behavior_analysis.git
```

You can now stay up-to-date with this branch by using ```git pull``` in the terminal (while in the repository directory).
