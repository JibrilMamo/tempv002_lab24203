#!/bin/bash
VIVADO_PATH=/soft/Vivado_Webpack/Vivado_Webpack/Vivado/2020.2/bin
CURPATH=`pwd`
score=0

if [ -f "$CURPATH/score.txt"  ];then
   rm "$CURPATH/score.txt" 
fi

touch "$CURPATH/score.txt"  

##First grade the ALU solution 
for func in "ADD" "SGT" "SRL" "XOR" "NAND"
do
   for idx in `seq 0 1 1`
   do
      cd $CURPATH
      if [ ! -d testing_path ]; then
          mkdir testing_path
      fi
      rm -rf testing_path/*
      cd testing_path
      for file in regs.dat imem.dat dmem.dat regs_result_expected.dat mem_result_expected.dat decoded_imem.dat
      do
         cp ../specific_tests/ALU/$func/$idx/$file .
      done
      cp ../*.sv .
      sed -i 's@filename=.*@filename=\"regs.dat\";@' parameters.sv
      sed -i 's@filename1=.*@filename1=\"dmem.dat\";@' parameters.sv 
      sed -i 's@filename2=.*@filename2=\"imem.dat\";@' parameters.sv 
      sed -i 's@filename3=.*@filename3=\"mem_result.dat\";@' parameters.sv 
      sed -i 's@filename4=.*@filename4=\"regs_result.dat\";@' parameters.sv
      $VIVADO_PATH/xvlog -sv parameters.sv control.sv decode.sv fetch.sv forward.sv mem.sv pcr.sv wb.sv execute.sv cpu.sv tb_cpu.sv
      $VIVADO_PATH/xelab -debug typical tb_cpu_p1 -s top_sim
      $VIVADO_PATH/xsim -R top_sim
      diff1=`diff regs_result.dat regs_result_expected.dat | wc -l`
      diff2=`diff mem_result.dat mem_result_expected.dat | wc -l`
      if [ $diff1 == "0"  ]; then
           if [ $diff2 == "0" ]; then
              score=`echo "scale=0;$score + 2" | bc`
              echo "2" >>  "$CURPATH/score.txt" 
           else
              echo "Mem result is incorrect for func $func, test idx $idx"
              echo "0" >>  "$CURPATH/score.txt" 
           fi
      else
           echo "Reg result is incorrect for func $func, test idx $idx"
           echo "0" >>  "$CURPATH/score.txt" 
      fi
  done
done
echo "The score is $score for ALU, out of a total possible 20" >> $CURPATH/score.txt

#Grade the remaining parts
score=0
for opcode in "CINDC" "BEQINIT"
do
   for idx in `seq 0 1 9`
   do
      cd $CURPATH
      if [ ! -d testing_path ]; then
          mkdir testing_path
      fi
      rm -rf testing_path/*
      cd testing_path
      for file in regs.dat imem.dat dmem.dat regs_result_expected.dat mem_result_expected.dat
      do
         cp ../specific_tests/$opcode/$idx/$file .
      done
      cp ../*.sv .
      sed -i 's@filename=.*@filename=\"regs.dat\";@' parameters.sv
      sed -i 's@filename1=.*@filename1=\"dmem.dat\";@' parameters.sv 
      sed -i 's@filename2=.*@filename2=\"imem.dat\";@' parameters.sv 
      sed -i 's@filename3=.*@filename3=\"mem_result.dat\";@' parameters.sv 
      sed -i 's@filename4=.*@filename4=\"regs_result.dat\";@' parameters.sv
      $VIVADO_PATH/xvlog -sv parameters.sv control.sv decode.sv fetch.sv forward.sv mem.sv pcr.sv wb.sv execute.sv cpu.sv tb_cpu.sv
      $VIVADO_PATH/xelab -debug typical tb_cpu_p1 -s top_sim 
      $VIVADO_PATH/xsim -R top_sim
      diff1=`diff regs_result.dat regs_result_expected.dat | wc -l`
      diff2=`diff mem_result.dat mem_result_expected.dat | wc -l`
      if [ $diff1 == "0"  ]; then
           if [ $diff2 == "0" ]; then
              score=`echo "scale=0;$score + 2" | bc`
              echo "2" >>  "$CURPATH/score.txt" 
           else
              echo "Mem result is incorrect for func $func, test idx $idx"
              echo "0" >>  "$CURPATH/score.txt" 
           fi
      else
           echo "Reg result is incorrect for func $func, test idx $idx"
           echo "0" >>  "$CURPATH/score.txt" 
      fi
   done
done
echo "The score is $score for all functions, out of a total possible 40" >> $CURPATH/score.txt

#Grade the miscellaneous test cases
score=0
for idx in `seq 0 1 0`
do
      cd $CURPATH
      if [ ! -d testing_path ]; then
          mkdir testing_path
      fi
      rm -rf testing_path/*
      cd testing_path
      for file in regs.dat imem.dat dmem.dat regs_result_expected.dat mem_result_expected.dat
      do
         cp ../random_tests/$idx/$file .
      done
      cp ../*.sv .
      sed -i 's@filename=.*@filename=\"regs.dat\";@' parameters.sv
      sed -i 's@filename1=.*@filename1=\"dmem.dat\";@' parameters.sv 
      sed -i 's@filename2=.*@filename2=\"imem.dat\";@' parameters.sv 
      sed -i 's@filename3=.*@filename3=\"mem_result.dat\";@' parameters.sv 
      sed -i 's@filename4=.*@filename4=\"regs_result.dat\";@' parameters.sv
      $VIVADO_PATH/xvlog -sv parameters.sv control.sv decode.sv fetch.sv forward.sv mem.sv pcr.sv wb.sv execute.sv cpu.sv tb_cpu.sv
      $VIVADO_PATH/xelab -debug typical tb_cpu_p1 -s top_sim 
      $VIVADO_PATH/xsim -R top_sim
      diff1=`diff regs_result.dat regs_result_expected.dat | wc -l`
      diff2=`diff mem_result.dat mem_result_expected.dat | wc -l`
      if [ $diff1 == "0"  ]; then
           if [ $diff2 == "0" ]; then
              score=`echo "scale=0;$score + 1" | bc`
              echo "Test case $idx worked correctly"
              echo "1" >>  "$CURPATH/score.txt" 
           else
              echo "Mem result is incorrect for func $func, test idx $idx"
              echo "0" >>  "$CURPATH/score.txt" 
           fi
      else
           echo "Reg result is incorrect for func $func, test idx $idx"
           echo "0" >>  "$CURPATH/score.txt" 
      fi
done
echo "The score is $score for the random testcases, out of a total possible 40" >> $CURPATH/score.txt
