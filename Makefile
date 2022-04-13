all: poker
poker: main.swift
	swiftc -o $@ $< 
.PHONY: clean
clean:
	rm poker
