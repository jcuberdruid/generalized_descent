set datafile separator ','
set title "Part 1D Error Plot: Gradient Descent 𝛄 = 8"
set xlabel "Iteration"
set ylabel "f(x^k) - p*, p* = 3.5185096e-07"

set logscale y
set terminal pngcairo enhanced size 800,600
set output 'gradient_descent__results_gamma_8.0.png' 

plot '../gradient_descent__results_gamma_8.0.csv' using 1:($4 - 3.5185096e-07) with linespoints linewidth 2 pointtype 7 pointsize 1.5 title 'Error'

set output
