import 'dart:io';
import 'dart:core';
import 'dart:convert';

const int OWN_PORT = 6969;
const int invalid_port = 69420;

class A
{
  A(int b)
  {
    if (b > 3) throw "ap";
    print("igen");
  }

  void prin()
  {
    print("teeeeee");
  }

}

void main()
{
  A a = A(3);
  a.prin();

  A b = A(4);
  a.prin();
}
