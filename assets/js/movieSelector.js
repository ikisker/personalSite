function removeMovie(index) {
    var movieListContainer = document.getElementById("movieList");
    movieListContainer.removeChild(movieListContainer.childNodes[index]);
}

function printMovieName() {
    var movieInput = document.getElementById("movieInput");
    var movieListContainer = document.getElementById("movieList");
    var enteredMovies = movieInput.value.split(",").map(movie => movie.trim()); // Trim spaces around movie names

    if (enteredMovies.length > 0 && enteredMovies[0] !== "") {
        for (var i = 0; i < enteredMovies.length; i++) {
            var movieItem = document.createElement("div");
            movieItem.className = "movieItem"; // Add a class for styling

            var removeButton = document.createElement("div");
            removeButton.className = "removeButton";
            removeButton.textContent = "x";
            removeButton.onclick = (function (index) {
                return function () {
                    removeMovie(index);
                };
            })(i);

            var movieName = document.createElement("div");
            movieName.textContent = enteredMovies[i];

            movieItem.appendChild(movieName);
            movieItem.appendChild(removeButton);
            movieListContainer.appendChild(movieItem); // Append each movie as a new div element
        }
    } 
    movieInput.value = ""; // Clear the input field
}

function selectRandomMovie() {
    var movieListContainer = document.getElementById("movieList");
    var movies = movieListContainer.getElementsByClassName("movieItem");

    if (movies.length > 0) {
        var randomIndex = Math.floor(Math.random() * movies.length);
        var randomMovie = movies[randomIndex].getElementsByTagName("div")[0].textContent;

        document.getElementById("popupContent").textContent = "Selected Movie: " + randomMovie;
        document.getElementById("popup").style.display = "block";
    } else {
        alert("Please add movies before selecting one.");
    }
}

function closePopup() {
    document.getElementById("popup").style.display = "none";
}
