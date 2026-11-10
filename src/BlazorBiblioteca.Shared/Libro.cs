using System.ComponentModel.DataAnnotations;

namespace BlazorBiblioteca.Shared;

public class Libro : IValidatableObject
{
    public int Id { get; set; }

    [Required(ErrorMessage = "Ingresa el nombre del libro.")]
    [StringLength(50, ErrorMessage = "El nombre admite un máximo de 50 caracteres.")]
    public string NombreLibro { get; set; } = string.Empty;

    [Required(ErrorMessage = "Ingresa el autor.")]
    [StringLength(50, ErrorMessage = "El autor admite un máximo de 50 caracteres.")]
    public string Autor { get; set; } = string.Empty;

    [Range(1, int.MaxValue, ErrorMessage = "El número de páginas debe ser un entero mayor que cero.")]
    public int NumPaginas { get; set; }

    public DateOnly FechaPublicacion { get; set; } = DateOnly.FromDateTime(DateTime.Today);

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (FechaPublicacion == DateOnly.MinValue)
            yield return new ValidationResult("Ingresa una fecha de publicación válida.", [nameof(FechaPublicacion)]);
    }
}
