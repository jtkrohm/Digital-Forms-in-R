**This GitHub repository (<https://github.com/jtkrohm/Health-Applications>) contains source code for all custom digital forms.
**


Each form provides a graphical user interface, and allows users to manually log their
information into an integrated document database using mongoDB



# Form: Line Bottle Testing

<img src="app/data/icon.svg" width="128" height="128" alt="line-bottle-testing" align="right" />

This form is optimised for beverage manufacturing.
The user interface contains two tabs:

 - **first tab**: displays data entry with fields such as time, bottle size, fill height and weight
 - **second tab**: Displays a table with the most recent form entries 
 that have been saved
 - **third tab**: Displays a graph which shows the variation of a single bottle metric using information from all the form entries



## Prerequisites
The source code requires mongoDB and Rsudio to be installed on the local machine: 

 - [RStudio](https://posit.co/download/rstudio-desktop/) 
 - [mongoDB](https://www.mongodb.com/docs/manual/installation/?msockid=21c90a505ee9627631511e555f8563e4#install-mongodb)
