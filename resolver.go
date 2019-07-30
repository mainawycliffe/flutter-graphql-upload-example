package backend

import (
	"context"
	"fmt"
	"io/ioutil"
	"os"
) // THIS CODE IS A STARTING POINT ONLY. IT WILL NOT BE UPDATED WITH SCHEMA CHANGES.

type Resolver struct{}

func (r *Resolver) Mutation() MutationResolver {
	return &mutationResolver{r}
}
func (r *Resolver) Query() QueryResolver {
	return &queryResolver{r}
}

type mutationResolver struct{ *Resolver }

func (r *mutationResolver) Upload(ctx context.Context, input FileUpload) (string, error) {
	f, err := os.Create(fmt.Sprintf("/tmp/%s", input.Name))

	if err != nil {
		return "", err
	}

	content, err := ioutil.ReadAll(input.File.File)

	if err != nil {
		return "", err
	}

	_, err = f.Write(content)

	if err != nil {
		return "", err
	}

	return input.Name, nil
}

type queryResolver struct{ *Resolver }

func (r *queryResolver) Hello(ctx context.Context, name string) (string, error) {
	return fmt.Sprintf("Hello, %s", name), nil
}
