import sympy as sp
x,y=sp.symbols('x,y')
f=(x**2)*y
sp.diff(f,x)
