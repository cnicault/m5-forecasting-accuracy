cls
@echo off
echo.
echo State CA
echo Store CA_1
@"c:\Program Files\R\R-3.6.3\bin\Rscript.exe" --vanilla --quiet models\store_script_eval_k84.R CA CA_1 lgb1 evaluation
echo Store CA_2
@"c:\Program Files\R\R-3.6.3\bin\Rscript.exe" --vanilla --quiet models\store_script_eval_k84.R CA CA_2 lgb1 evaluation
echo Store CA_3
@"c:\Program Files\R\R-3.6.3\bin\Rscript.exe" --vanilla --quiet models\store_script_eval_k87.R CA CA_3 lgb1 evaluation
echo Store CA_4
@"c:\Program Files\R\R-3.6.3\bin\Rscript.exe" --vanilla --quiet models\store_script_eval_k90.R CA CA_4 lgb1 evaluation

echo State WI
echo Store WI_1
@"c:\Program Files\R\R-3.6.3\bin\Rscript.exe" --vanilla --quiet models\store_script_eval_k87.R WI WI_1 lgb1 evaluation
echo Store WI_2
@"c:\Program Files\R\R-3.6.3\bin\Rscript.exe" --vanilla --quiet models\store_script_eval_k87.R WI WI_2 lgb2 evaluation
echo Store WI_3
@"c:\Program Files\R\R-3.6.3\bin\Rscript.exe" --vanilla --quiet models\store_script_eval_k90.R WI WI_3 lgb1 evaluation

echo State TX
echo Store TX_1
@"c:\Program Files\R\R-3.6.3\bin\Rscript.exe" --vanilla --quiet models\store_script_eval_k87.R TX TX_1 lgb2 evaluation
echo Store TX_2
@"c:\Program Files\R\R-3.6.3\bin\Rscript.exe" --vanilla --quiet models\store_script_eval_k91.R TX TX_2 lgb2 evaluation
echo Store TX_3
@"c:\Program Files\R\R-3.6.3\bin\Rscript.exe" --vanilla --quiet models\store_script_eval_k91.R TX TX_3 lgb2 evaluation