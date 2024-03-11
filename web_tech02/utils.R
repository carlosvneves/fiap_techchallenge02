# bibliotecas

# utilidades
library(readr)

# manipulação de dados
library(tidyverse)
library(dplyr)

# séries temporais
library(lubridate)
library(tseries)
library(strucchange)
library(urca)
library(xgboost)
library(timetk)
library(modeltime)
library(lubridate)
library(tidymodels)
library(modeltime.gluonts)
library(modeltime.h2o)
library(Metrics)

# output
library(ggplot2)
library(ggthemes)
library(knitr)
library(kableExtra)
library(plotly, warn.conflicts = FALSE)
library(treemapify)
library(TSstudio)

# cria o operador de negação
`%notin%` <- Negate(`%in%`)    

# helper functions

#' Remove outliers 
remove_outliers <- function(data, col){
    
    x <- as_vector(data[col])
    
    quartiles <- quantile(x, probs=c(.25, .75), na.rm = FALSE)
    IQR <- IQR(x)
    
    Lower <- quartiles[1] - 1.5*IQR
    Upper <- quartiles[2] + 1.5*IQR 
    
    data_no_outlier <- subset(data, x > Lower & x < Upper)
    
    outliers <- data[-which( x %in% data_no_outlier[col]),]
    
    return(c(data_no_outlier, outliers))
    
}

#' Render beautiful tables
tbl_render <- function(tbl, header){
    
    
    tbl_col_names <- c()
    
    
    for (name in colnames(tbl)) {
        if (name == 'date') {
            name = "Dia/Mês/Ano"
        } else if (name == 'country') {
            name = "País"
        } else if (name == 'value') {
            name = "Valor FOB (US$)"
        } else if (name == 'volume'){
            name = "Quilograma Líquido (1L=1Kg)"
        } else if (name == 'kpi'){
            name = "KPI"
        } else{
            name = NULL
        }
        
        if(!is.null(name)) {
            tbl_col_names <- c(tbl_col_names, name)
        }
        
    }
    
    return(
        if( 'date' %in% colnames(tbl)) {
            DT::datatable(tbl, filter = "bottom", 
                          colnames = tbl_col_names,
                          # caption = header, 
                          extensions = 'Buttons', 
                          options = list(
                              dom = 'Bfrtip',
                              buttons = c('copy','excel', 'csv', 'pdf')
                          )) |>
                DT::formatCurrency(columns = c('value'), "$") |>
                DT::formatDate(columns = c('date'),
                               'toLocaleDateString') |>
                DT::formatRound(columns = c('volume'),
                                mark = ".",
                                dec.mark = ",")  
        } else if('kpi' %in% colnames(tbl)){
            DT::datatable(tbl, filter = "bottom", 
                          colnames = tbl_col_names,
                          # caption = header, 
                          extensions = 'Buttons', 
                          options = list(
                              dom = 'Bfrtip',
                              buttons = c('copy','excel', 'csv', 'pdf')
                          )) |>
                DT::formatCurrency(columns = c('value'), "$") |>
                DT::formatDate(columns = c('date'),
                               'toLocaleDateString') |>
                DT::formatRound(columns = c('volume'),
                                mark = ".",
                                dec.mark = ",")   |> 
                DT::formatRound(columns = c('kpi'),
                                mark = ".",
                                dec.mark = ",")
        } else {
            DT::datatable(tbl, filter = "bottom", 
                          colnames = tbl_col_names,
                          # caption = header, 
                          extensions = 'Buttons', 
                          options = list(
                              dom = 'Bfrtip',
                              buttons = c('copy','excel', 'csv', 'pdf')
                          )) |>
                DT::formatCurrency(columns = c('value'), "$") |>
                DT::formatRound(columns = c('volume'),
                                mark = ".",
                                dec.mark = ",", digits = 3)
            
        }
    )
    
}

#' Unit Root tests
ur_test <- function(ts, type_adf, type_kpss){
    
    
    # não rejeita a estacionariedade
    adf_test <- urca::ur.df(ts, type = type_adf, selectlags = "AIC", lags = 12)
    stats <- rbind(as.vector(adf_test@cval[,"5pct"]), 
                   as.vector(adf_test@teststat)
    )
    cnames <- colnames(adf_test@teststat)
    rownames(stats) <- c("cvals","stats")
    colnames(stats) <- cnames
    
    pvalue <- fUnitRoots::adfTest(ts, type = "nc")@test$p.value
    
    resp_adf <- paste(
    "############################
    \rResultado do Teste ADF
    \r############################\n
    \rp-valor:", 
    round(pvalue,3)
    )
    cat(resp_adf)
    cat("\n\nEstatísticas do teste ADF (5% de significância):\n\n")
    print(stats)
    
    
    
    
    kpss_test <- urca::ur.kpss(ts, type = type_kpss, lags = "short")
    stat <- kpss_test@teststat
    cval <- kpss_test@cval[,"5pct"]
    resp_kpss <- format(paste(
        "############################
    \rResultado do Teste KPSS
    \r############################\n
    \rValor crítico a 5% de significância:", 
    round(cval,3)
    ), trim = TRUE)
    cat("\n\n")
    cat(resp_kpss)
    cat(format(paste("\n\nEstatística do teste KPSS:",round(stat[1],3)), trim = TRUE))
    
}