import os 
os.environ["PYCARET_CUSTOM_LOGGING_LEVEL"] = "CRITICAL"

import time 
import numpy as np
import pandas as pd

from pycaret.datasets import get_data
from pycaret.time_series import TSForecastingExperiment



def setup()->tuple:
    # y:pd.DataFrame = get_data("airline", verbose=False)
    y:pd.DataFrame = pd.read_csv("./data/Ibovespa_20210101-202424.csv", index_col=0, parse_dates=True)
    fh = 12
    fold = 3     
    fig_kwargs = {
        "renderer":"png",
        "height":600,
        "width":1000,
    }
    return y, fh, fold, fig_kwargs

def eda(y, fh, fold, fig_kwargs):
    eda = TSForecastingExperiment()
    eda.setup(
        data=y,
        fh=fh,
        # fold=fold,
        fig_kwargs=fig_kwargs,
        use_gpu = False,
    )
    eda.plot_model(data_kwargs={"plot_data_type":["original","imputed","transformed"]}, save=True)
    eda.plot_model(plot="acf", data_kwargs={"lags":36}, save=True)
    eda.plot_model(plot="pacf", data_kwargs={"lags":36}, save=True)
    eda.plot_model(plot="periodogram",save=True)
    eda.plot_model(plot="fft", save=True)
    eda.plot_model(plot="diagnostics", save=True)



def main():
    print("# Inciando a análise")
    y, fh, fold, fig_kwargs = setup()
    # eda(y, fh, fold, fig_kwargs)



if __name__ == "__main__":
    main()
