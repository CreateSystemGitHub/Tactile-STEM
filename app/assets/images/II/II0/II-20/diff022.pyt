x,y,dx,dy=sp.symbols('x,y,dx,dy')
f=(x**2)*y
sp.diff(f,x)*dx+sp.diff(f,y)*dy
