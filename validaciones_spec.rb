require 'rspec'

class ValidacionException < Exception
end

class Module
  def validaciones(sym, &block)
    metodo_original_sym = "#{sym}_ant".to_sym
    alias_method metodo_original_sym, sym

    define_method sym do |*args|
      unless instance_exec *args, &block
        raise ValidacionException.new
      end
      self.send metodo_original_sym, *args
    end
  end
end

class A
  attr_accessor :valor_esperado, :valor_actual

  def initialize(valor_esperado)
    self.valor_esperado = valor_esperado
  end

  def m
    42
  end

  def m_conparam(a)
    a
  end

  validaciones :m do
    self.valor_esperado == self.valor_actual
  end

  validaciones :m_conparam do |a|
    self.valor_esperado == a
  end
end

describe 'Agregamos validaciones' do

  it '' do
    a = A.new(3)
    a.valor_actual = 3
    expect(a.m).to eq(42)
  end

  it 'falla' do
    a = A.new(3)
    a.valor_actual = 2
    expect { a.m }.to raise_error(ValidacionException)
  end

  it 'falla test conparam' do
    a = A.new(1)
    expect {a.m_conparam(3)}.to raise_error(ValidacionException)
  end

  it 'no falla test conparam' do
    a = A.new(1)
    expect(a.m_conparam(1)).to eq(1)
  end
end