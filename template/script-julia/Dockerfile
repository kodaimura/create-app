FROM julia:1.12.6

WORKDIR /app

COPY Project.toml main.jl ./
COPY test ./test

CMD ["julia", "--project=.", "main.jl"]
