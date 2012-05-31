# Here's a script where given a file,
# it figures out all the methods defined in that file and finds
# all method calls within those methods. Now I need to see if
# each of THOSE method calls is valid.
#
# how to see if a method call is valid:
# if it's called on an object, and it is not in that object's
# methods, then it's invalid.
#
# Next step: if it's called on an object, get that object's type (class).
# Then get that object's methods.

# ^that is sort of done too. Things not taken into consideration:
# - scoping. we assume global scope for a LOT of things.
# - multiple args. we assume single args for almost everything.
#
# Ideally, what would make this really nice is if we could provide
# a scope and see all the shit happening in that scope?

require 'rubygems'
require 'ruby2ruby'
require 'pp'
require 'ruby_parser'
require 'ruby-debug'
class Foo < SexpProcessor
  @@calls = []
  @@lasgns = []
  @@allreqs = []
  def initialize
    super
    self.auto_shift_type = true
  end

  def self.calls
    @@calls
  end

  def self.lasgns
    @@lasgns
  end

  def self.allreqs
    @@allreqs
  end

  def self.find_deep(_node, node_name)
    to_check = [_node]
    nodes_found = []
    to_check.each do |node|
      node.each do |part|
        if part.class == Sexp
          to_check << part
          if part.node_type == node_name
            nodes_found << part
          end
        end
      end
    end
    nodes_found
  end

  def self.process_assigns(_sexp)
    # adds to lasgns an array [variable name, variable's class]
    sexp = _sexp.to_a
    name = sexp[1]
    assn = sexp[2]
    real_assn = nil
    case assn[0]
    when :call
      # instance of a class
      if assn[2] == :new
        real_assn = assn[1][1]
      end
    end
    @@lasgns << [name, real_assn]
  end

  def self.process(sexp)
    # sexp.each { |x| puts ">>#{x}" }
    # p sexp.find_nodes(:defn)
    # p sexp.sexp_type
    # p sexp.sexp_body
    # p sexp.structure
    #
    # function definitions
    find_deep(sexp, :defn).each {|x| process_fn(x) }
    klasses = sexp.find_nodes(:class)
    # instance methods in classes
    klasses.each do |klass|
      defns = find_deep(klass, :defn)
      # defss = find_deep(klass, :defs)
      defns.each { |x| process_fn(x) }
    end

    # assignments
    find_deep(sexp, :lasgn).each { |x| process_assigns(x) }
    
    # function calls
    p "@@@@"
    pp sexp
    calls = sexp.find_nodes(:call)
    process_calls(sexp, calls)
    sexp
  end

  # here I could do, assuming the call is in the global scope,
  # and if I'm calling it with a variable, that variable is in
  # the global scope too, then get that variable assignment ("lasgn")
  # and see what class it's getting initialized from (this assumes it's
  # not a string etc and it's not being assigned from *another* var)
  # and then check that class to see what methods it has, both builtin
  # and explicit. Is this called method one of those methods?
  #
  # To get the list of builtin methods, I need to either have that list
  # handy somewhere or I need to require that file and then do classname.instance_methods
  # or whatever
  #
  # Kernel.const_get(:String).instance_methods for example.
  def self.typecheck(sexp)
    p ">>#{sexp}"
    #pp PARSED.find_nodes(:call)
    pp PARSED
  end

  # function body, array of all the calls it makes
  # this doesn't work well when sexp is the whole file instead
  # of a function.
  def self.process_calls(sexp, calls)
    # array of [var name, method it should have]
    main_func_name = sexp[1]
    reqs = []
    calls.each do |call|
      func_name = call[2]
      args = []
      lvar = call.find_node(:lvar)
      if lvar
        varname = lvar[1]
        reqs << [varname, func_name]
        args << varname
      end
      call.find_nodes(:self).each { |var| args << var[0] }
      call.find_nodes(:arglist).first.to_a[1,1000].each { |var| args << var[1] }
      @@calls << [func_name, args]
    end
    @@allreqs << [main_func_name, reqs]
  end

  def self.process_fn(sexp)
    calls = find_deep(sexp, :call)
    process_calls(sexp, calls)
  end

  def process_defn(sexp)
    sexp
  end

  def process_class(sexp)
    p sexp
    sexp
  end
end

ruby      = File.open(ARGV[0], "r").read
require ARGV[0]
parser    = RubyParser.new
PARSED    = parser.process(ruby)
sexp      = Foo.process(PARSED)
puts "calls: #{Foo.calls.inspect}"
puts "assignments: #{Foo.lasgns.inspect}"
puts "all requirements for functions: #{Foo.allreqs.inspect}"

to_check = Foo.allreqs.select do |funcname, reqs|
  reqs != []
end

to_check.each do |funcname, reqs|
  # lets assume that any variable here was passed in
  # to the function as an argument.

  # list of all calls to this function
  func_calls = Foo.calls.select { |name, _| name == funcname }

  # test each call, see if it's valid
  func_calls.each do |_, args|
    # let's pretend we only deal with one arg for now
    arg = args[0]
    if arg.is_a?(Symbol)
      # assuming this func call was in the global namespace,
      # and the assignment was in the global namespace too
      #
      # the class of this arg
      klass = Foo.lasgns.select { |name, cls| name == arg }[0][1]
      methods = Kernel.const_get(klass).instance_methods
    end

    # now check to make sure the function in reqs is in the list of methods
    # not using varname for now because we assume there's only one var
    reqs.each do |varname, _required_func|
      required_func = _required_func.to_s
      unless methods.include?(required_func)
        puts "Holy crap! Class #{klass} does not have a method #{required_func}! But it's being used in #{funcname}!"
      end
    end
  end
end

#ruby2ruby = Ruby2Ruby.new
#p ruby2ruby.process(sexp)
