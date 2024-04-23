---
title: "Exercise"
author: "Julian Flowers"
date: "2024-04-23"
output:
  html_document:
    code_folding: hide
    toc: true
    keep_md: true
  pdf_document:
    toc: true
  word_document:
    toc: true
    fig_caption: true
    fig_height: 8
    fig_width: 6
subtitle: "Drawing inference and insight from diabetes data"
bibliography: references.bib
---



## Introduction

In this exercise we will be using data from the English Public Health Outcomes Framework (PHOF). We will be downloading data from source and the exercise is to test the relationship between diabetes care processes and outcome.

To do this we will be performing supervised analysis of diabetes data from the PHOF - constructing linear models with diabetes outcome as the dependent variable and care processes and the independent (predictor) variables. To allow for diabetes frequency we will also include diabetes prevalence in our models, as well as a summary measure of socio-economic status (SES). In England, the Index of Multiple Deprivation 2019 (IMD) is widely used as a summary SES index.

We will be analysing the data for sub-national health administrative units called sub-ICBs (SICB). England is subdivided into 104 SICBs - these are the units of health care planning and performance.

## Get started

First we need to load the R packages we need to extract data and for analysis.


```r
needs(tidyverse, pak, tidymodels, mgcv, glmnet, corrplot, factoextra, FactoMineR, umap, dbscan, broom, cluster, fpc)
```

## Get the data

Now we load the diabetes data. he code segment below shows how data is loaded.


```r
diabetes_model <- read_csv("https://github.com/julianflowers/spha/blob/main/dm_model_data.csv?raw=TRUE", show_col_types = FALSE)
diabetes_codebook <- read_csv("https://github.com/julianflowers/spha/blob/main/dmmod_codebook.csv?raw=TRUE", show_col_types = FALSE)
```

The resulting dataset has 104 records, and consists of 84 diabetes metrics.

## Explore the data




The first step is explore relationships between variables. A common way to do this is to construct a correlation matrix or a correlogram. In R, the `corrplot` package is widely used for this.

![](diabetes_model_files/figure-html/corrplot-1.png)<!-- -->

## Cluster analysis

The next step is to identify patterns in the data. We'll start with cluster analysis - this has two main forms - hierarchical and non-hierarchical. Hierarchical clustering creates a tree diagram (dendrogram)

### Hierarchical clustering

The groups areas which have similar patterns of indicator values

![](diabetes_model_files/figure-html/scale_model_data_cluster-1.png)<!-- -->

## Clustering algorithms

A recent approach to identifying patterns in large multivariate datasets is to take a 2 step approach:

1.  Dimensionality reduction - first collapse the data to 2 dimensions. There are several ways to do this including principal component analysis (PCA), Uniform Manifold Approximation and Projection (UMAP)[@Hozumi2021; @umap]. UMAP is increasingly used because it preserves small scale structure in the data and can emphasize clustering.
2.  Then apply a clustering algorithm. DBSCAN is often used (@dbscan). This doesn't require pre-specified cluster number, but it is based on a nearest neighbour algorithm. The choice of nearest neighbour count (`minPts`) determines the number of clusters found by the algorithm.

![](diabetes_model_files/figure-html/umap_and_cluster-1.png)<!-- -->

## Cluster features

Next, we can review how the clusters differ in terms of diabetes indicators.

![](diabetes_model_files/figure-html/cluster_features-1.png)<!-- -->

## Modelling diabetes control and outcome




### Population diabetes outcomes

First we'll explore the relationship between diabetes outcome and diabetes control. We will use minor amputation rates as an outcome measure (Lower is better), and diabetes control metrics as predictors We'll use the most recent values of predictor variables (2020). The latest year for amputation rates is 2018.

#### Linear model


```{=html}
<div id="osncjrvket" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#osncjrvket table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#osncjrvket thead, #osncjrvket tbody, #osncjrvket tfoot, #osncjrvket tr, #osncjrvket td, #osncjrvket th {
  border-style: none;
}

#osncjrvket p {
  margin: 0;
  padding: 0;
}

#osncjrvket .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#osncjrvket .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#osncjrvket .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#osncjrvket .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#osncjrvket .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#osncjrvket .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#osncjrvket .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#osncjrvket .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#osncjrvket .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#osncjrvket .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#osncjrvket .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#osncjrvket .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#osncjrvket .gt_spanner_row {
  border-bottom-style: hidden;
}

#osncjrvket .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#osncjrvket .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#osncjrvket .gt_from_md > :first-child {
  margin-top: 0;
}

#osncjrvket .gt_from_md > :last-child {
  margin-bottom: 0;
}

#osncjrvket .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#osncjrvket .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#osncjrvket .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#osncjrvket .gt_row_group_first td {
  border-top-width: 2px;
}

#osncjrvket .gt_row_group_first th {
  border-top-width: 2px;
}

#osncjrvket .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#osncjrvket .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#osncjrvket .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#osncjrvket .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#osncjrvket .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#osncjrvket .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#osncjrvket .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}

#osncjrvket .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#osncjrvket .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#osncjrvket .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#osncjrvket .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#osncjrvket .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#osncjrvket .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#osncjrvket .gt_left {
  text-align: left;
}

#osncjrvket .gt_center {
  text-align: center;
}

#osncjrvket .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#osncjrvket .gt_font_normal {
  font-weight: normal;
}

#osncjrvket .gt_font_bold {
  font-weight: bold;
}

#osncjrvket .gt_font_italic {
  font-style: italic;
}

#osncjrvket .gt_super {
  font-size: 65%;
}

#osncjrvket .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}

#osncjrvket .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#osncjrvket .gt_indent_1 {
  text-indent: 5px;
}

#osncjrvket .gt_indent_2 {
  text-indent: 10px;
}

#osncjrvket .gt_indent_3 {
  text-indent: 15px;
}

#osncjrvket .gt_indent_4 {
  text-indent: 20px;
}

#osncjrvket .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="&lt;strong&gt;Characteristic&lt;/strong&gt;"><strong>Characteristic</strong></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="&lt;strong&gt;Beta&lt;/strong&gt;"><strong>Beta</strong></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="&lt;strong&gt;95% CI&lt;/strong&gt;&lt;span class=&quot;gt_footnote_marks&quot; style=&quot;white-space:nowrap;font-style:italic;font-weight:normal;&quot;&gt;&lt;sup&gt;1&lt;/sup&gt;&lt;/span&gt;"><strong>95% CI</strong><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;"><sup>1</sup></span></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="&lt;strong&gt;p-value&lt;/strong&gt;"><strong>p-value</strong></th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="label" class="gt_row gt_left">ind_59</td>
<td headers="estimate" class="gt_row gt_center">-0.69</td>
<td headers="ci" class="gt_row gt_center">-1.5, 0.10</td>
<td headers="p.value" class="gt_row gt_center">0.087</td></tr>
    <tr><td headers="label" class="gt_row gt_left">ind_62</td>
<td headers="estimate" class="gt_row gt_center">0.45</td>
<td headers="ci" class="gt_row gt_center">0.17, 0.74</td>
<td headers="p.value" class="gt_row gt_center">0.002</td></tr>
    <tr><td headers="label" class="gt_row gt_left">ind_65</td>
<td headers="estimate" class="gt_row gt_center">0.01</td>
<td headers="ci" class="gt_row gt_center">-0.58, 0.61</td>
<td headers="p.value" class="gt_row gt_center">>0.9</td></tr>
    <tr><td headers="label" class="gt_row gt_left">ind_68</td>
<td headers="estimate" class="gt_row gt_center">-0.42</td>
<td headers="ci" class="gt_row gt_center">-1.0, 0.18</td>
<td headers="p.value" class="gt_row gt_center">0.2</td></tr>
    <tr><td headers="label" class="gt_row gt_left">ind_71</td>
<td headers="estimate" class="gt_row gt_center">0.41</td>
<td headers="ci" class="gt_row gt_center">0.01, 0.81</td>
<td headers="p.value" class="gt_row gt_center">0.042</td></tr>
    <tr><td headers="label" class="gt_row gt_left">ind_74</td>
<td headers="estimate" class="gt_row gt_center">0.21</td>
<td headers="ci" class="gt_row gt_center">-0.17, 0.59</td>
<td headers="p.value" class="gt_row gt_center">0.3</td></tr>
    <tr><td headers="label" class="gt_row gt_left">ind_77</td>
<td headers="estimate" class="gt_row gt_center">0.00</td>
<td headers="ci" class="gt_row gt_center">-0.06, 0.05</td>
<td headers="p.value" class="gt_row gt_center">>0.9</td></tr>
    <tr><td headers="label" class="gt_row gt_left">ind_80</td>
<td headers="estimate" class="gt_row gt_center">0.01</td>
<td headers="ci" class="gt_row gt_center">-0.06, 0.09</td>
<td headers="p.value" class="gt_row gt_center">0.8</td></tr>
    <tr><td headers="label" class="gt_row gt_left">ind_84</td>
<td headers="estimate" class="gt_row gt_center">0.33</td>
<td headers="ci" class="gt_row gt_center">-0.21, 0.87</td>
<td headers="p.value" class="gt_row gt_center">0.2</td></tr>
    <tr><td headers="label" class="gt_row gt_left">ind_81</td>
<td headers="estimate" class="gt_row gt_center">0.03</td>
<td headers="ci" class="gt_row gt_center">-0.04, 0.10</td>
<td headers="p.value" class="gt_row gt_center">0.4</td></tr>
  </tbody>
  <tfoot class="gt_sourcenotes">
    <tr>
      <td class="gt_sourcenote" colspan="4">R² = 0.326; Adjusted R² = 0.253; Sigma = 1.81; Statistic = 4.49; p-value = &lt;0.001; df = 10; Log-likelihood = -203; AIC = 431; BIC = 462; Deviance = 304; Residual df = 93; No. Obs. = 104</td>
    </tr>
  </tfoot>
  <tfoot class="gt_footnotes">
    <tr>
      <td class="gt_footnote" colspan="4"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;"><sup>1</sup></span> CI = Confidence Interval</td>
    </tr>
  </tfoot>
</table>
</div>
```

Simple linear regression suggests that the proportion of the population achieving all 3 treatment targets is inversely associated with lower minor amputation rates. It is positively associated with tight blood pressure control and tight diabetes control. The model explains 32.56% of the variance in minor amputation rates. The root mean squared error is 1.71.

#### Non-linear model

We can extend our inferential model to include non-linear relationships. We can use the `mgcv` package to fit a generalised additive model (GAM) to the data. This allows us to model non-linear relationships between the dependent and independent variables.


```{=html}
<div id="yncngcwvzo" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#yncngcwvzo table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#yncngcwvzo thead, #yncngcwvzo tbody, #yncngcwvzo tfoot, #yncngcwvzo tr, #yncngcwvzo td, #yncngcwvzo th {
  border-style: none;
}

#yncngcwvzo p {
  margin: 0;
  padding: 0;
}

#yncngcwvzo .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#yncngcwvzo .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#yncngcwvzo .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#yncngcwvzo .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#yncngcwvzo .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#yncngcwvzo .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#yncngcwvzo .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#yncngcwvzo .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#yncngcwvzo .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#yncngcwvzo .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#yncngcwvzo .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#yncngcwvzo .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#yncngcwvzo .gt_spanner_row {
  border-bottom-style: hidden;
}

#yncngcwvzo .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#yncngcwvzo .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#yncngcwvzo .gt_from_md > :first-child {
  margin-top: 0;
}

#yncngcwvzo .gt_from_md > :last-child {
  margin-bottom: 0;
}

#yncngcwvzo .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#yncngcwvzo .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#yncngcwvzo .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#yncngcwvzo .gt_row_group_first td {
  border-top-width: 2px;
}

#yncngcwvzo .gt_row_group_first th {
  border-top-width: 2px;
}

#yncngcwvzo .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#yncngcwvzo .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#yncngcwvzo .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#yncngcwvzo .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#yncngcwvzo .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#yncngcwvzo .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#yncngcwvzo .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}

#yncngcwvzo .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#yncngcwvzo .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#yncngcwvzo .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#yncngcwvzo .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#yncngcwvzo .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#yncngcwvzo .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#yncngcwvzo .gt_left {
  text-align: left;
}

#yncngcwvzo .gt_center {
  text-align: center;
}

#yncngcwvzo .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#yncngcwvzo .gt_font_normal {
  font-weight: normal;
}

#yncngcwvzo .gt_font_bold {
  font-weight: bold;
}

#yncngcwvzo .gt_font_italic {
  font-style: italic;
}

#yncngcwvzo .gt_super {
  font-size: 65%;
}

#yncngcwvzo .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}

#yncngcwvzo .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#yncngcwvzo .gt_indent_1 {
  text-indent: 5px;
}

#yncngcwvzo .gt_indent_2 {
  text-indent: 10px;
}

#yncngcwvzo .gt_indent_3 {
  text-indent: 15px;
}

#yncngcwvzo .gt_indent_4 {
  text-indent: 20px;
}

#yncngcwvzo .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="&lt;strong&gt;Characteristic&lt;/strong&gt;"><strong>Characteristic</strong></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="&lt;strong&gt;Beta&lt;/strong&gt;"><strong>Beta</strong></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="&lt;strong&gt;95% CI&lt;/strong&gt;&lt;span class=&quot;gt_footnote_marks&quot; style=&quot;white-space:nowrap;font-style:italic;font-weight:normal;&quot;&gt;&lt;sup&gt;1&lt;/sup&gt;&lt;/span&gt;"><strong>95% CI</strong><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;"><sup>1</sup></span></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="&lt;strong&gt;p-value&lt;/strong&gt;"><strong>p-value</strong></th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="label" class="gt_row gt_left">s(ind_59)</td>
<td headers="estimate" class="gt_row gt_center"><br /></td>
<td headers="ci" class="gt_row gt_center"><br /></td>
<td headers="p.value" class="gt_row gt_center">0.042</td></tr>
    <tr><td headers="label" class="gt_row gt_left">s(ind_62)</td>
<td headers="estimate" class="gt_row gt_center"><br /></td>
<td headers="ci" class="gt_row gt_center"><br /></td>
<td headers="p.value" class="gt_row gt_center"><0.001</td></tr>
    <tr><td headers="label" class="gt_row gt_left">s(ind_65)</td>
<td headers="estimate" class="gt_row gt_center"><br /></td>
<td headers="ci" class="gt_row gt_center"><br /></td>
<td headers="p.value" class="gt_row gt_center">0.079</td></tr>
    <tr><td headers="label" class="gt_row gt_left">s(ind_68)</td>
<td headers="estimate" class="gt_row gt_center"><br /></td>
<td headers="ci" class="gt_row gt_center"><br /></td>
<td headers="p.value" class="gt_row gt_center">0.2</td></tr>
    <tr><td headers="label" class="gt_row gt_left">s(ind_71)</td>
<td headers="estimate" class="gt_row gt_center"><br /></td>
<td headers="ci" class="gt_row gt_center"><br /></td>
<td headers="p.value" class="gt_row gt_center">0.081</td></tr>
    <tr><td headers="label" class="gt_row gt_left">s(ind_74)</td>
<td headers="estimate" class="gt_row gt_center"><br /></td>
<td headers="ci" class="gt_row gt_center"><br /></td>
<td headers="p.value" class="gt_row gt_center">0.3</td></tr>
    <tr><td headers="label" class="gt_row gt_left">s(ind_77)</td>
<td headers="estimate" class="gt_row gt_center"><br /></td>
<td headers="ci" class="gt_row gt_center"><br /></td>
<td headers="p.value" class="gt_row gt_center">0.7</td></tr>
    <tr><td headers="label" class="gt_row gt_left">s(ind_80)</td>
<td headers="estimate" class="gt_row gt_center"><br /></td>
<td headers="ci" class="gt_row gt_center"><br /></td>
<td headers="p.value" class="gt_row gt_center">0.6</td></tr>
    <tr><td headers="label" class="gt_row gt_left">s(ind_84)</td>
<td headers="estimate" class="gt_row gt_center"><br /></td>
<td headers="ci" class="gt_row gt_center"><br /></td>
<td headers="p.value" class="gt_row gt_center">0.3</td></tr>
    <tr><td headers="label" class="gt_row gt_left">s(ind_81)</td>
<td headers="estimate" class="gt_row gt_center"><br /></td>
<td headers="ci" class="gt_row gt_center"><br /></td>
<td headers="p.value" class="gt_row gt_center">0.2</td></tr>
  </tbody>
  <tfoot class="gt_sourcenotes">
    <tr>
      <td class="gt_sourcenote" colspan="4">df = 23; Log-likelihood = -183; AIC = 413; BIC = 476; Deviance = 204; Residual df = 81; No. Obs. = 104</td>
    </tr>
  </tfoot>
  <tfoot class="gt_footnotes">
    <tr>
      <td class="gt_footnote" colspan="4"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;"><sup>1</sup></span> CI = Confidence Interval</td>
    </tr>
  </tfoot>
</table>
</div>
```

```
## 
## Family: gaussian 
## Link function: identity 
## 
## Formula:
## ind_85 ~ s(ind_59) + s(ind_62) + s(ind_65) + s(ind_68) + s(ind_71) + 
##     s(ind_74) + s(ind_77) + s(ind_80) + s(ind_84) + s(ind_81)
## 
## Parametric coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept)    7.962      0.155    51.2   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Approximate significance of smooth terms:
##            edf Ref.df     F p-value    
## s(ind_59) 6.86   7.90  2.19   0.042 *  
## s(ind_62) 1.00   1.00 19.75 2.8e-05 ***
## s(ind_65) 4.90   6.03  1.97   0.079 .  
## s(ind_68) 1.00   1.00  1.98   0.163    
## s(ind_71) 1.00   1.00  3.13   0.081 .  
## s(ind_74) 1.00   1.00  0.98   0.326    
## s(ind_77) 1.00   1.00  0.11   0.742    
## s(ind_80) 1.00   1.00  0.22   0.641    
## s(ind_84) 1.00   1.00  1.23   0.271    
## s(ind_81) 3.06   3.79  1.72   0.151    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## R-sq.(adj) =  0.427   Deviance explained = 54.8%
## GCV = 3.2167  Scale est. = 2.5108    n = 104
```

This shows 4 variables, blood pressure control, diabetes control, cholesterol control and HbA1c control are non-linearly associated with minor amputation rates. The model explains 55% of the variance in minor amputation rates. The root mean squared error is 1.4 - the model is a better fit than the linear version


We can plot the relationship between the predictors and the outcome to visualise the non-linear relationships.

![Plot of GAM model of diabetes control and minor amputation rates](diabetes_model_files/figure-html/gam_plot-1.png)

This confirms the lack of relationship with ind_77, ind_80 and ind_65, inverse linear relationships with ind_59 and ind_68, and positive relationship with ind_62 and ind_71. The other predictors show a weak non-linear relationship with minor amputation rates.

Decoding these relationships, we learn that the proportion of the diabetic population achieving treatment targets is inversely associated with minor amputation rates - this is encouraging as it suggests that better control of diabetes is associated with lower rates of minor amputations. The relationship is linear, with the lowest minor amputation rates seen at the highest levels of diabetes control, and suggests a target for further reduction in amputation rates by increasing the percentage controlled (currently below 44%), and reducing the variation between areas.

Somewhat paradoxically, individual treatment targets - ind_62 (cholesterol control) and ind_71 (blood pressure control) are positively associated with minor amputation rates, suggesting that 


The proportion of the population achieving all 3 treatment targets is a measure of population treatment control. We'll use the most recent value (ind_59) as the dependent variable, and the most recent values of predictor variables (2020).



To further explore the relationship between achieving all 3 treatment targets and the predictors we can use a linear model. Initially we will fit all predictors (process, demography and prevalence estimates).

![](diabetes_model_files/figure-html/linear_process_model-1.png)<!-- -->

The chart shows a linear model is a moderate fit with an r squared value is 0.52. There is residual variation - the root mean squared error is 2.07 is 2.1. This means our model predicts the proportion of the population achieving all 3 treatment targets within 2.1% of the observed value.

With a large number of predictors, model selection (i.e. best fit choice of predictor variables) is important. We can use the `step` function to select the best model i.e. performance of the model with the fewest predictors. However, penalised regression is a more efficient technique. This automatically selects the best model by penalising the number of predictors. In R the `glmnet` package is widely used for this (@glmnet). It uses lasso regression to remove variables which contribute least to the model.

![](diabetes_model_files/figure-html/penalised_regression-1.png)<!-- -->![](diabetes_model_files/figure-html/penalised_regression-2.png)<!-- -->

The error of this model is 2.09 - similar to the linear model

## Plot regression coefficients

![Demographic, prevalence and care process predictors of population diabetes control](diabetes_model_files/figure-html/coeff_plot-1.png)


## Annex

**Algorithm of DBSCAN**

The goal is to identify dense regions, which can be measured by the number of objects close to a given point.

Two important parameters are required for **DBSCAN**: **epsilon** (“eps”) and **minimum points** (“MinPts”). The parameter **eps** defines the radius of neighbourhood around a point x. It’s called called the $\epsilon$-neighbourhood of x. The parameter **MinPts** is the minimum number of neighbours within “eps” radius.

Any point x in the dataset, with a neighbour count greater than or equal to **MinPts**, is marked as a **core point**. We say that x is **border point**, if the number of its neighbours is less than MinPts, but it belongs to the $\epsilon$-neighbourhood of some core point z. Finally, if a point is neither a core nor a border point, then it is called a noise point or an outlier.

The figure below shows the different types of points (core, border and outlier points) using **MinPts = 6**. Here x is a core point because $neighbours_\epsilon(x) = 6$, y is a border point because $neighbours_\epsilon(y) < MinPts$, but it belongs to the $\epsilon$-neighbourhood of the core point x. Finally, z is a noise point.

![Density based clustering basic idea - minimal point and epsilon](http://www.sthda.com/sthda/RDoc/images/dbscan-principle.png)

We define 3 terms, required for understanding the **DBSCAN algorithm**:

-   **Direct density reachable**: A point “A” is **directly density reachable** from another point “B” if: i) “A” is in the $\epsilon$-neighbourhood of “B” and ii) “B” is a core point.

-   **Density reachable**: A point “A” is **density reachable** from “B” if there are a set of core points leading from “B” to “A.

-   **Density connected**: Two points “A” and “B” are **density connected** if there are a core point “C”, such that both “A” and “B” are **density reachable** from “C”.

A **density-based cluster** is defined as a group of density connected points. The algorithm of density-based clustering (DBSCAN) works as follow:

The algorithm of density-based clustering works as follow:

1.  For each point $x_i$, compute the distance between $x_i$ and the other points. Finds all neighbour points within distance **eps** of the starting point ($x_i$). Each point, with a neighbour count greater than or equal to **MinPts**, is marked as **core point** or **visited**.

2.  For each **core point**, if it’s not already assigned to a cluster, create a new cluster. Find recursively all its density connected points and assign them to the same cluster as the core point.

3.  Iterate through the remaining unvisited points in the dataset.

Those points that do not belong to any cluster are treated as outliers or noise
