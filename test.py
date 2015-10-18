from pyswip import Prolog

prolog = Prolog()

prolog.assertz("hello(test)")
prolog.assertz("hello(world)")

print list(prolog.query("hello(world)"))
print list(prolog.query("hello(x)"))

for result in prolog.query("hello(X)"):
    print result["X"]

print "--------------"
for result in prolog.query("retractall(hello(_))"):
    continue

for result in prolog.query("hello(X)"):
    print result["X"]

print "--------------"
