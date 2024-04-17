set datafile separator ','
set title "Part 1B Error Plot: Gradient Descent 𝛄 = 2"
set xlabel "Iteration"
set ylabel "f(x^k) - p*, p* = 5.5189343e-08"

set logscale y
set terminal pngcairo enhanced size 800,600
set output 'gradient_descent__results_2.0.png'

plot '../gradient_descent__results_2.0.csv' using 1:($4 - 5.5189343e-08) with linespoints linewidth 2 pointtype 7 pointsize 1.5 title 'Error'

set output
