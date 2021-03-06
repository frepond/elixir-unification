defmodule Unification do
	@moduledoc """
		Toy implementation of MGU Haskell algorithm by Paul Callaghan.
		Used just to test some basic Elixir.
	"""

	@empty_subst HashDict.new()

	defrecordp :var, name: "" :: String
  defrecordp :fun, name: "" :: String, terms: [] :: [uterm]

  @type uterm :: var_t | fun_t
  @type subst :: :nothing | Dict.t

  defimpl Inspect, for: :var do
  	@doc """
  	Implementation of `Inspect` protocol for `Var` records

		`{:var, n}` is just trasnlated to `n` using `Kernel.inspect/2`
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

  @spec vars_in(uterm) :: Set.t
  def vars_in term do
  	case term do
  		{:var, v} -> 
  			HashSet.new([v])
  		{:fun, _, ts} -> 
  			List.foldl (lc x inlist ts, do: vars_in x), HashSet.new, (fn(s1, s2) -> Set.union s1, s2 end)
  	end
  end

  @spec uapply(subst, uterm) :: uterm
  defp uapply substs, term do
  	case term do
  		{:var, v} -> 
  			Dict.get(substs, v, {:var, v})
  		{:fun, n, terms} -> 
  			{:fun, n, Enum.map(terms, fn x -> uapply substs, x end)}
  	end
  end

  @spec uapplyl(subst, [uterm]) :: [uterm]
  defp uapplyl substs, terms do
  	Enum.map terms, fn(t) -> uapply substs, t end
  end

  @spec unify(uterm, uterm) :: subst
  def unify lst, rst do
  	case {lst, rst} do
  		{{:var, lvn}, {Var, lvn}} -> 
  			@empty_subst
  		{{:var, lvn}, {:var, rvn}} -> 
  			Dict.put @empty_subst, lvn, {:var, rvn}
  		{{:var, lvn}, {:fun, rfn, ts}} ->
  			if Set.member? vars_in({:fun, rfn, ts}), lvn do
  				:nothing
  			else
  				Dict.put @empty_subst, lvn, {:fun, rfn, ts}
  			end
  		{{:fun, lfn, ts}, {:var, rvn}} ->
  			if Set.member? vars_in({:fun, lfn, ts}), rvn do
  				:nothing
  			else 
  				Dict.put @empty_subst, rvn, {:fun, lfn, ts}
  			end
  		{{:fun, lfn, lts}, {:fun, rfn, rts}} ->	
  			if lfn !== rfn, do: :nothing, else: unifyl(lts, rts)
  	end
  end

  @spec unifyl([uterm], [uterm]) :: subst
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
  			s2 = if s1 === :nothing, do: :nothing, else: unifyl(uapplyl(s1, ls), uapplyl(s1, rs))
  			if s2 === :nothing, do: :nothing, else: Dict.merge(s1, s2)
  	end	
  end

  @spec mk_var(String) :: var_t
  def mk_var name do
  	var(name: name)
	end

	@spec mk_fun(String, [uterm]) :: fun_t
	def mk_fun name, terms do
		fun(name: name, terms: terms)
	end
end