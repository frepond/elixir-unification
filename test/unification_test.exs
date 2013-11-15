defmodule UnificationTest do
  use ExUnit.Case
  import Unification

  # TODO: this should be tested using generators ala quickcheck

  test "terms" do
  	var1 = mk_var "V1"
		var2 = mk_var "V1"
		var3 = mk_var "V2"

		fn1 = mk_fun "f1", [var1]
		fn2 = mk_fun "f1", [var1]
		fn3 = mk_fun "f1", [var3]
		fn4 = mk_fun "f2", [var1]

		const = mk_fun "true", []
		fixed = mk_fun "x", [] 

  	assert(var1 == var2)
  	assert(var1 != var3)
  	assert(fn1 == fn2)
  	assert(fn1 != fn3)
  	assert(fn1 != fn4)
  end

  test "vars_in" do
  	var1 = mk_var "V1"
		var2 = mk_var "V1"
		var3 = mk_var "V2"

		const = mk_fun "true", []
		fixed = mk_fun "x", [] 

		fn1 = mk_fun "f1", [var1]
		fn2 = mk_fun "f1", [var1]
		fnn = mk_fun "fun", [var1, var2, fn1, fn2, const, fixed, var3]

  	empty_set = HashSet.new()
  	v1_set = HashSet.new(["V1"])
  	fnn_set = HashSet.new(["V1", "V2"])

  	assert(vars_in(const) == empty_set)
  	assert(vars_in(fixed) == empty_set)

  	assert(vars_in(var1) == v1_set)
  	assert(vars_in(fn1) == v1_set)

  	assert(vars_in(fnn) == fnn_set)
  end

  test "unification" do
  	f1 = mk_fun "f", [mk_var("V1"), mk_fun("g", [mk_fun("x", [])])]
	 	f2 = mk_fun "f", [mk_fun("y", []), mk_fun("g", [mk_var("V3")])]

	 	assert(unify(f1, f2) == HashDict.new([{"V1", mk_fun("y", [])}, {"V3", mk_fun("x", [])}]))


		f3 = mk_fun "f", [mk_var("V1"), mk_var("V2")]
		f4 = mk_fun "f", [mk_var("V3"), mk_fun("x", [])]

		assert(unify(f3, f4) == HashDict.new([{"V1", mk_var("V3")}, {"V2", mk_fun("x", [])}]))

		f5 = mk_fun "f", [mk_var("V3"), mk_fun("y", [])]

		assert(unify(f4, f5) == :nothing)
  end
end


# var1 = Unification.Var.new name: "V1"
# var2 = Unification.Var.new name: "V1"
# var3 = Unification.Var.new name: "V2"

# fn1 = Unification.Fun.new name: "F1", terms: [var1]
# fn2 = Unification.Fun.new name: "F1", terms: [var1]
# fn3 = Unification.Fun.new name: "F1", terms: [var3]
# fn4 = Unification.Fun.new name: "F2", terms: [var1]

# const = Unification.Fun.new name: "true", terms: []
# fixed = Unification.Fun.new name: "V4", terms: []


# f1 = Unification.mk_fun "f", [Unification.mk_var("V1"), Unification.mk_fun("g", [Unification.mk_fun("x", [])])]
# f2 = Unification.mk_fun "f", [Unification.mk_fun("y", []), Unification.mk_fun("g", [Unification.mk_var("V3")])]

# f1 = Unification.mk_fun "f", [Unification.mk_var("V1"), Unification.mk_var("V2")]
# f2 = Unification.mk_fun "f", [Unification.mk_var("V3"), Unification.mk_fun("x", [])]

