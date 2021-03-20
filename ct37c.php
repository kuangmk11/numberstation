#!/usr/bin/php
<?php

$input = strtolower(file_get_contents('php://stdin'));

/*
CT-37c
  | 0    1    2    3    4    5    6    7    8    9
  +---------------------------------------------------
  | code A    E    I    N    O    T
 7| B    C    D    F    G    H    J    K    L    M
 8| P    Q    R    S    U    V    W    X    Y    Z
 9| fig  .    :    '    ()   +    -    =    req  sp

* for code
& for req
*/
$letters = array('a', 'e', 'i', 'n', 'o', 't', 'b',  'c',  'd',  'f',  'g',  'h',  'j',  'k',  'l',  'm',  'p',  'q',  'r',  's',  'u',  'v',  'w',  'x',  'y',  'z',  '.',  ':',  ';',  '"',  "'",  ',',  '(',  ')',  '+',  '-',  '=',  '&',  ' ', PHP_EOL);
$numbers = array('1', '2', '3', '4', '5', '6', '70', '71', '72', '73', '74', '75', '76', '77', '78', '79', '80', '81', '82', '83', '84', '85', '86', '87', '88', '89', '91', '92', '92', '93', '93', '93', '94', '94', '95', '96', '97', '98', '99');

// replace numbers and codes
$strlen = strlen($input);
$temp   = '';
$fig = false;
for ($i=0; $i<$strlen; $i++) {
  // number
  if (is_numeric($input[$i])) {
    if (!$fig) {
      $temp .= '90';
      $fig = true;
    }
    $temp .= $input[$i] . $input[$i] . $input[$i];
    if ($i+1 < $strlen) {
      if (!is_numeric($input[$i+1])) {
        $temp .= '90';
        $fig = false;
      }
    } else if ($fig) {
      $temp .= '90';
    }

  // code
  } else if ($input[$i] == '*') {
    $temp .= '0' . substr($input, $i+1, 3);
    $i += 3;
  // anything else
  } else {
    $temp .= $input[$i];
  }
}
$input = $temp;

$output = str_replace($letters, $numbers, $input);

// pad end with 9s
$padsize = strlen($output) % 5;
if ($padsize != 0) {
  $pad = str_pad('', 5-$padsize, '9');
  $output .= $pad;
}

echo chunk_split($output, 5, ' ') . PHP_EOL;

