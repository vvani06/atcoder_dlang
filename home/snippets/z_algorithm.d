
int[] zAlgorithm(string s) {
  auto ret = new int[](s.length);
  ret[0] = s.length.to!int;

  int i = 1, j = 0;
  while (i < s.length) {
    while (i + j < s.length && s[j] == s[i + j]) j++;
    ret[i] = j;
    if (j == 0) {
      i++;
      continue;
    }

    int k = 1;
    while (i + k < s.length && k + ret[k] < j) {
      ret[i + k] = ret[k];
      k++;
    }

    i += k;
    j -= k;
  }  

  return ret;
}
