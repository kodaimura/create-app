package main

import "testing"

func TestGreeting(t *testing.T) {
	t.Parallel()

	want := "Hello, Go!"
	if got := greeting(); got != want {
		t.Fatalf("greeting() = %q, want %q", got, want)
	}
}
