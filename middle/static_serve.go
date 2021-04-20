package middle

import (
	"net/http"
	"os"
	"path"
	"strings"

	"github.com/gin-gonic/gin"
)

const INDEX = "index.html"

type ServeFileSystem interface {
	http.FileSystem
	Exists(prefix string, path string) bool
}

type localFileSystem struct {
	http.FileSystem
	root    string
	indexes bool
}

func LocalFile(root string, indexes bool) *localFileSystem {
	return &localFileSystem{
		FileSystem: gin.Dir(root, indexes),
		root:       root,
		indexes:    indexes,
	}
}

func (l *localFileSystem) Exists(prefix string, filepath string) bool {
	if p := strings.TrimPrefix(filepath, prefix); len(p) < len(filepath) {
		name := path.Join(l.root, p)
		stats, err := os.Stat(name)
		if err != nil {
			return false
		}
		if stats.IsDir() {
			if !l.indexes {
				index := path.Join(name, INDEX)
				_, err := os.Stat(index)
				if err != nil {
					return false
				}
			}
		}
		return true
	}
	return false
}

// Static returns a middleware handler that serves static files in the `static` directory from root path.
func ServeStatic() gin.HandlerFunc {
	fs := LocalFile("./static", false)
	fileserver := http.FileServer(fs)
	fileserver = http.StripPrefix("/", fileserver)

	return func(c *gin.Context) {
		if c.Request.Method == http.MethodGet {
			// check whether asset exists in `static` file
			if fs.Exists("/", c.Request.URL.Path) {
				fileserver.ServeHTTP(c.Writer, c.Request)
				c.Abort()
				return
			}

			// default to `index.html` when not using api
			if !strings.Contains(c.Request.URL.Path, "/api/") {
				c.File("./static/index.html")
				c.Abort()
				return
			}
		}

		// normal api
		c.Next()
	}
}
