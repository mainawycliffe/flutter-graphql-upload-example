package backend

import (
	"context"
	"fmt"
	"io/ioutil"
	"log"
	"os"

	"github.com/99designs/gqlgen/graphql"
) // THIS CODE IS A STARTING POINT ONLY. IT WILL NOT BE UPDATED WITH SCHEMA CHANGES.

type Resolver struct{}

func (r *Resolver) Mutation() MutationResolver {
	return &mutationResolver{r}
}
func (r *Resolver) Query() QueryResolver {
	return &queryResolver{r}
}

type mutationResolver struct{ *Resolver }

func (r *mutationResolver) Upload(ctx context.Context, input graphql.Upload) (string, error) {
	f, err := os.Create(fmt.Sprintf("temp/%s", input.Filename))

	if err != nil {
		log.Printf("Error: %v", err)
		return "", err
	}

	content, err := ioutil.ReadAll(input.File)

	if err != nil {
		log.Printf("Error: %v", err)
		return "", err
	}

	_, err = f.Write(content)

	if err != nil {
		log.Printf("Error: %v", err)
		return "", err
	}

	return fmt.Sprintf("http://localhost:8080/temp/%s", input.Filename), nil
}

type queryResolver struct{ *Resolver }

func (r *queryResolver) Hello(ctx context.Context, name string) (string, error) {
	return fmt.Sprintf("Hello, %s", name), nil
}
