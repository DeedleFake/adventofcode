package iter

type Iter[T any] func(func(T) bool) bool
