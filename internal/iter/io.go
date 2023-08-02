package iter

import (
	"bufio"
	"io"
)

func scan[T any](s *bufio.Scanner, data func(*bufio.Scanner) T) Iter[T] {
	return func(yield func(T) bool) bool {
		for s.Scan() {
			if !yield(data(s)) {
				break
			}
		}
		return false
	}
}

func ScanText(s *bufio.Scanner) Iter[string] {
	return scan(s, (*bufio.Scanner).Text)
}

func ScanBytes(s *bufio.Scanner) Iter[[]byte] {
	return scan(s, (*bufio.Scanner).Bytes)
}

func Lines(r io.Reader, err *error) Iter[string] {
	s := bufio.NewScanner(r)
	return func(yield func(string) bool) bool {
		ScanText(s)(yield)
		*err = s.Err()
		return false
	}
}
