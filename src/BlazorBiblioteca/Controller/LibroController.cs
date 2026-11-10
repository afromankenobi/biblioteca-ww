using BlazorBiblioteca.Context;
using BlazorBiblioteca.Shared;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BlazorBiblioteca.Controller;

[ApiController]
[Route("api/[controller]")]
public class LibroController(LibroDBContext context) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<List<Libro>>> Listar(CancellationToken cancellationToken) =>
        await context.Libros.AsNoTracking().OrderBy(x => x.Id).ToListAsync(cancellationToken);

    [HttpGet("{id:int}")]
    public async Task<ActionResult<Libro>> Obtener(int id, CancellationToken cancellationToken)
    {
        var libro = await context.Libros.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id, cancellationToken);
        return libro is null ? NotFound() : Ok(libro);
    }

    [HttpPost]
    public async Task<ActionResult<Libro>> Agregar(Libro libro, CancellationToken cancellationToken)
    {
        // SQL Server genera el Id; el navegador no decide su valor.
        if (libro.Id != 0) return BadRequest("El Id de un libro nuevo debe ser cero.");
        libro.NombreLibro = libro.NombreLibro.Trim();
        libro.Autor = libro.Autor.Trim();
        context.Libros.Add(libro);
        await context.SaveChangesAsync(cancellationToken);
        return CreatedAtAction(nameof(Obtener), new { id = libro.Id }, libro);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Actualizar(int id, Libro datos, CancellationToken cancellationToken)
    {
        if (id != datos.Id) return BadRequest("El Id de la ruta y del libro deben coincidir.");
        var libro = await context.Libros.FirstOrDefaultAsync(x => x.Id == id, cancellationToken);
        if (libro is null) return NotFound();
        libro.NombreLibro = datos.NombreLibro.Trim();
        libro.Autor = datos.Autor.Trim();
        libro.NumPaginas = datos.NumPaginas;
        libro.FechaPublicacion = datos.FechaPublicacion;
        try { await context.SaveChangesAsync(cancellationToken); }
        catch (DbUpdateConcurrencyException) { return NotFound(); }
        return NoContent();
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Eliminar(int id, CancellationToken cancellationToken)
    {
        var libro = await context.Libros.FirstOrDefaultAsync(x => x.Id == id, cancellationToken);
        if (libro is null) return NotFound();
        context.Libros.Remove(libro);
        try { await context.SaveChangesAsync(cancellationToken); }
        catch (DbUpdateConcurrencyException) { return NotFound(); }
        return NoContent();
    }
}
