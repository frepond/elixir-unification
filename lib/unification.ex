defmodule Unification do
	@moduledoc """
		Toy implementation of MGU Haskell algorithm by Paul Callaghan.
		Used just to test some basic Elixir.
	"""

	@type term :: Var | Fun
	@type subst :: HashDict

	@empty_subst HashDict.new()

	defrecordp :var, name: ""
  
  defrecordp :fun, name: "", terms: []

  defimpl Inspect, for: :var do
  	@doc """
  	Implementation of `Inspect` protocol for `Var` records

		`{Var, n}` is just trasnlated to `n` using `Kernel.inspect/2`
  	"""

  	def inspect {:var, name}, opts do
  		Kernel.inspect name, opts
  	end
  end

  defimpl Inspect, for: :fun do
  	import Inspect.Algebra

  	@doc """
  	Implementation of `Inspect` protocol for `Fun` records

  	`Fun` are inspected recursively, for example:
			
			{Fun, name: "F1", terms [{Fun, name: "F2", []}, {Var, name: "V1"}]} 

			is translated to

			F1(F2(), V1)
  	"""

  	def inspect {:fun, name, terms}, opts do
  		case terms do
  			[] ->
  				Kernel.inspect name
  			_ ->
  				concat name, surround("(", inspectl(terms, opts), ")")
  		end
  	end

  	defp inspectl terms, opts do
  		folddoc Enum.map(terms, fn(t) -> Kernel.inspect(t, opts) end), fn(x, y) -> concat [x, ", ", y] end
  	end
  end

  @spec vars_in(list(term)) :: list
  def vars_in term do
  	case term do
  		{:var, v} -> 
  			HashSet.new([v])
  		{:fun, _, ts} -> 
  			List.foldl (lc x inlist ts, do: vars_in x), HashSet.new, (fn(s1, s2) -> Set.union s1, s2 end)
  	end
  end

  @spec uapply(subst, term) :: term
  def uapply substs, term do
  	case term do
  		{Var, v} -> 
  			HashDict.get(substs, v, {:var, v})
  		{:fun, n, terms} -> 
  			{:fun, n, Enum.map(terms, fn x -> uapply substs, x end)}
  	end
  end

  defp uapplyl substs, terms do
  	Enum.map terms, fn(t) -> uapply substs, t end
  end

  @spec unify(term, term) :: subst
  def unify lst, rst do
  	case {lst, rst} do
  		{{:var, lvn}, {Var, lvn}} -> 
  			@empty_substitution
  		{{:var, lvn}, {:var, rvn}} -> 
  			HashDict.put @empty_subst, lvn, {:var, rvn}
  		{{:var, lvn}, {:fun, rfn, ts}} ->
  			if HashSet.member?(vars_in({:fun, rfn, ts}), lvn) do
  				:nothing
  			else
  				HashDict.put(@empty_subst, lvn, {:fun, rfn, ts})
  			end
  		{{:fun, lfn, ts}, {Var, rvn}} ->
  			if HashSet.member?(vars_in({:fun, lfn, ts}), rvn) do
  				:nothing
  			else 
  				HashDict.put(@empty_subst, rvn, {:fun, lfn, ts})
  			end
  		{{:fun, lfn, lts}, {:fun, rfn, rts}} ->	
  			if lfn != rfn, do: :nothing, else: unifyl(lts, rts)
  	end
  end

  defp unifyl left, right do
  	case {left, right} do
  		{[], []} ->
  			@empty_subst
  		{[], _} -> 
  			:nothing
  		{_, []} ->
  			:nothing
  		{[l|ls], [r|rs]} ->
  			s1 = unify l, r
  			s2 = if s1 == :nothing, do: :nothing, else: unifyl(uapplyl(s1, ls), uapplyl(s1, rs))
  			if s2 == :nothing, do: :nothing, else: HashDict.merge(s1, s2)
  	end	
  end

  def mk_var name do
  	var(name: name)
	end

	def mk_fun name, terms do
		fun(name: name, terms: terms)
	end
end