alias build_a="dmd -debug -of/tmp/a_out a.d && time /tmp/a_out < input/a"
alias build_b="dmd -debug -of/tmp/b_out b.d && time /tmp/b_out < input/b"
alias build_c="dmd -debug -of/tmp/c_out c.d && time /tmp/c_out < input/c"
alias build_d="dmd -debug -of/tmp/d_out d.d && time /tmp/d_out < input/d"
alias build_e="dmd -debug -of/tmp/e_out e.d && time /tmp/e_out < input/e"
alias build_f="dmd -debug -of/tmp/f_out f.d && time /tmp/f_out < input/f"

alias release_a="dmd -wi -m64 -O -release -inline -boundscheck=off -of/tmp/a_out a.d && time /tmp/a_out < input/a"
alias release_b="dmd -wi -m64 -O -release -inline -boundscheck=off -of/tmp/b_out b.d && time /tmp/b_out < input/b"
alias release_c="dmd -wi -m64 -O -release -inline -boundscheck=off -of/tmp/c_out c.d && time /tmp/c_out < input/c"
alias release_d="dmd -wi -m64 -O -release -inline -boundscheck=off -of/tmp/d_out d.d && time /tmp/d_out < input/d"
alias release_e="dmd -wi -m64 -O -release -inline -boundscheck=off -of/tmp/e_out e.d && time /tmp/e_out < input/e"
alias release_f="dmd -wi -m64 -O -release -inline -boundscheck=off -of/tmp/f_out f.d && time /tmp/f_out < input/f"

function build() {
    dmd -debug -of/tmp/$1_out $1.d && time /tmp/$1_out < input/$1
}
function release() {
    dmd -wi -m64 -O -release -inline -boundscheck=off -of/tmp/$1_out $1.d && time /tmp/$1_out < input/$1
}