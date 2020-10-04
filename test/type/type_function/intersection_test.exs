defmodule TypeTest.TypeFunction.IntersectionTest do
  use ExUnit.Case, async: true
  use Type.Operators

  @moduletag :intersection

  import Type, only: [builtin: 1]
  alias Type.Function

  @any builtin(:any)
  @any_function %Function{params: :any, return: @any}
  @zero_arity_any %Function{params: [], return: @any}
  @one_arity_any %Function{params: [@any], return: @any}
  @two_arity_any %Function{params: [@any, @any], return: @any}

  describe "the any function" do
    test "intersects with any and self" do
      assert @any_function == Type.intersection(@any_function, @any)
      assert @any_function == Type.intersection(@any, @any_function)

      assert @any_function == Type.intersection(@any_function, @any_function)
    end

    test "matches the arity of parameters" do
      # zero arity
      assert @zero_arity_any == Type.intersection(@any_function, @zero_arity_any)
      # one arity
      assert @one_arity_any == Type.intersection(@any_function, @one_arity_any)
      # two arity
      assert @two_arity_any == Type.intersection(@any_function, @two_arity_any)

      # arbitrary params
      assert %Function{params: [builtin(:integer)], return: @any} ==
        Type.intersection(@any_function, %Function{params: [builtin(:integer)], return: @any})
    end

    test "reduces return" do
      assert %Function{params: :any, return: builtin(:integer)} ==
        Type.intersection(@any_function, %Function{params: :any, return: builtin(:integer)})
    end

    test "reduces both" do
      assert %Function{params: [builtin(:integer)], return: builtin(:integer)} ==
        Type.intersection(@any_function, %Function{params: [builtin(:integer)], return: builtin(:integer)})
    end

    test "intersects with nothing else" do
      TypeTest.Targets.except([%Function{params: [], return: 0}])
      |> Enum.each(fn target ->
        assert builtin(:none) == Type.intersection(@any_function, target)
      end)
    end
  end

  describe "a function with any parameters" do
    @any_with_integer %Function{params: :any, return: builtin(:integer)}
    test "intersects with self and the any function" do
      assert @any_with_integer == Type.intersection(@any_with_integer, @any_with_integer)
      assert @any_with_integer == Type.intersection(@any_with_integer, @any_function)
    end

    test "matches the arity of parameters" do
      # zero arity
      assert %Function{params: [], return: builtin(:integer)} ==
          Type.intersection(@any_with_integer, @zero_arity_any)
      # one arity
      assert %Function{params: [@any], return: builtin(:integer)} ==
          Type.intersection(@any_with_integer, @one_arity_any)
      # two arity
      assert %Function{params: [@any, @any], return: builtin(:integer)} ==
          Type.intersection(@any_with_integer, @two_arity_any)

      # arbitrary params
      assert %Function{params: [builtin(:integer)], return: builtin(:integer)} ==
        Type.intersection(@any_with_integer, %Function{params: [builtin(:integer)], return: @any})
    end

    test "reduces return" do
      assert %Function{params: :any, return: 1..10} ==
        Type.intersection(@any_with_integer, %Function{params: :any, return: 1..10})
    end

    test "reduces both" do
      assert %Function{params: [builtin(:integer)], return: 1..10} ==
        Type.intersection(@any_with_integer, %Function{params: [builtin(:integer)], return: 1..10})
    end

    test "is none if the returns don't match" do
      assert builtin(:none) == Type.intersection(@any_with_integer, %Function{params: :any, return: builtin(:atom)})
    end
  end

  describe "a function with defined parameters" do
    test "intersects with self and the any function" do
      # zero arity
      assert @zero_arity_any == Type.intersection(@zero_arity_any, @any_function)
      assert @zero_arity_any == Type.intersection(@zero_arity_any, @zero_arity_any)

      # one arity
      assert @one_arity_any == Type.intersection(@one_arity_any, @any_function)
      assert @one_arity_any == Type.intersection(@one_arity_any, @one_arity_any)

      # two arity
      assert @two_arity_any == Type.intersection(@two_arity_any, @any_function)
      assert @two_arity_any == Type.intersection(@two_arity_any, @two_arity_any)
    end

    test "must match arities" do
      assert builtin(:none) == Type.intersection(@zero_arity_any, @one_arity_any)
      assert builtin(:none) == Type.intersection(@zero_arity_any, @two_arity_any)
      assert builtin(:none) == Type.intersection(@one_arity_any, @two_arity_any)
    end

    test "reduces the return type" do
      assert %Function{params: [], return: builtin(:integer)} ==
        Type.intersection(@zero_arity_any, %Function{params: [], return: builtin(:integer)})

      assert %Function{params: [@any], return: builtin(:integer)} ==
        Type.intersection(@one_arity_any, %Function{params: [@any], return: builtin(:integer)})

      assert %Function{params: [@any, @any], return: builtin(:integer)} ==
        Type.intersection(@two_arity_any, %Function{params: [@any, @any], return: builtin(:integer)})
    end

    test "reduces parameter types" do
      assert %Function{params: [builtin(:integer)], return: @any} ==
        Type.intersection(@one_arity_any, %Function{params: [builtin(:integer)], return: @any})

      assert %Function{params: [builtin(:integer), @any], return: @any} ==
        Type.intersection(@two_arity_any, %Function{params: [builtin(:integer), @any], return: @any})

      assert %Function{params: [@any, builtin(:atom)], return: @any} ==
        Type.intersection(@two_arity_any, %Function{params: [@any, builtin(:atom)], return: @any})
    end

    test "reduces both" do
      assert %Function{params: [builtin(:atom)], return: builtin(:integer)} ==
        Type.intersection(@one_arity_any, %Function{params: [builtin(:atom)], return: builtin(:integer)})
    end
  end

end
