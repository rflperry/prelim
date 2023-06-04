#! /bin/bash
# TODO B, D
setupvals=('B' 'D') # 'A' 'B' 'C' 'D')
nvals=(250 500) # (500 1000)
pvals=(6) # (6 12)
sigmavals=(0.5 1.0 3.0) # (0.5 1.0 2.0 4.0)
lassoalgvals=('R' 'RS' 'T' 'X' 'U' 'oracle' 'S')
boostalgvals=('R' 'T' 'X' 'U' 'oracle' 'S' 'causalboost')
kernelalgvals=('R' 'T' 'X' 'U' 'oracle' 'S')

# TODO:
# - oracle, S on 0.5 and n=1000
# - all on 3 and n=1000
# - all on all sigma, all n, setups B,C,D 

lassoreps=500 # 50 #00 # 00 # 500
boostreps=200 # 00 # 200 
kernelreps=100 # 00 # 200

learners=('lasso') # 'lasso' 'kernel')

for ((i1=0; i1<${#setupvals[@]} ;i1++))
do
for ((i2=0; i2<${#nvals[@]} ;i2++))
do
for ((i3=0; i3<${#pvals[@]} ;i3++))
do
for ((i4=0; i4<${#sigmavals[@]} ;i4++))
do
for ((i5=0; i5<${#learners[@]} ;i5++))
do

    setup=${setupvals[$i1]}
    n=${nvals[$i2]}
    p=${pvals[$i3]}
    sigma=${sigmavals[$i4]}
    learner=${learners[$i5]}

    if [ "$learner" = "boost" ]; then
      algvals=( "${boostalgvals[@]}" )
      reps=$boostreps
    elif [ "$learner" = "lasso" ]; then
      algvals=( "${lassoalgvals[@]}" )
      reps=$lassoreps
    elif [ "$learner" = "kernel" ]; then
      algvals=( "${kernelalgvals[@]}" )
      reps=$kernelreps
    else
      echo "learner needs to be lasso or boost or kernel for the experiments.";
      exit 1;
    fi

    for ((i6=0; i6<${#algvals[@]} ;i6++))
    do
      while [ `ps aux | grep -wc run_simu.R` -ge 4 ] # limit at most 96 R scripts running at one time; should be adjusted depending on the machine
      do
         sleep 5
      done
      alg=${algvals[$i6]}
      fnm="logging_lasso/progress-$alg-$learner-$setup-$n-$p-$sigma-$reps.out"

      OMP_NUM_THREADS=1 Rscript scripts/run_simu.R $alg $learner $setup $n $p $sigma $reps 2>&1 | tee $fnm &
      echo "OMP_NUM_THREADS=1 Rscript scripts/run_simu.R $alg $learner $setup $n $p $sigma $reps 2>&1 | tee $fnm &"
    done
done
done
done
done
done

echo "DONE"
