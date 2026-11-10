using BlazorBiblioteca.Shared;
using Microsoft.EntityFrameworkCore;

namespace BlazorBiblioteca.Context;

public class LibroDBContext(DbContextOptions<LibroDBContext> options) : DbContext(options)
{
    public DbSet<Libro> Libros => Set<Libro>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        var libro = modelBuilder.Entity<Libro>();
        libro.ToTable("Libros", "dbo");
        libro.HasKey(x => x.Id);
        libro.Property(x => x.Id).UseIdentityColumn(1, 1);
        libro.Property(x => x.NombreLibro).HasMaxLength(50).IsUnicode(false).IsRequired();
        libro.Property(x => x.Autor).HasMaxLength(50).IsUnicode(false).IsRequired();
        libro.Property(x => x.NumPaginas).IsRequired();
        libro.Property(x => x.FechaPublicacion).HasColumnType("date").IsRequired();
    }
}
