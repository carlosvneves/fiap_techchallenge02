import os
import time

import numpy as np
import pandas as pd

from pycaret.datasets import get_data
from pycaret.time_series import TSForecastingExperiment 
os.environ['PYCARET_CUSTOM_LOG_LEVEL'] = 'CRITICAL'


def setup() -> tuple:
    y:pd.DataFrame = get_data("airline", verbose=False)
    fh:int = 12 #12 meses de forecasting, 3 fold para cross-validation
    fold:int = 3 

    fig_kwargs = {
        "renderer": "png",
        "height": 600,
        "width": 1000,
    }

    return y, fh, fold, fig_kwargs


def eda(y:pd.Series, fh:int, fold:int, fig_kwargs:dict):
    eda = TSForecastingExperiment()
    eda.setup(data=y, fh=fh, fig_kwargs=fig_kwargs)
    eda.plot_model(plot="ts")



def main():
    print("Iniciando análise")

    print("** Setup e carregamento de dados **")

    y, fh, fold, fig_kwargs = setup()
    
    print("** Análise Exploratória **")

    eda(y, fh, fold, fig_kwargs)










if __name__ == "__main__":
    main()  
