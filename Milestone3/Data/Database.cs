using System.Data;
using System.Data;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

public class Database
{
    private readonly string _connectionString;

    public Database(IConfiguration config)
    {
        _connectionString = config.GetConnectionString("DefaultConnection");
    }


    public async Task<DataTable> ExecuteStoredProcedure(string procName, params SqlParameter[] parameters)
    {
        using var conn = new SqlConnection(_connectionString);
        using var cmd = new SqlCommand(procName, conn);
        cmd.CommandType = CommandType.StoredProcedure;

        if (parameters != null)
            cmd.Parameters.AddRange(parameters);

        await conn.OpenAsync();

        using var reader = await cmd.ExecuteReaderAsync();
        var dt = new DataTable();
        dt.Load(reader);
        return dt;
    }

    public async Task<DataTable> ExecuteQuery(string sqlQuery, params SqlParameter[] parameters)
    {
        using var conn = new SqlConnection(_connectionString);
        using var cmd = new SqlCommand(sqlQuery, conn);
        cmd.CommandType = CommandType.Text;

        if (parameters != null)
            cmd.Parameters.AddRange(parameters);

        await conn.OpenAsync();

        using var reader = await cmd.ExecuteReaderAsync();
        var dt = new DataTable();
        dt.Load(reader);
        return dt;
    }

    public async Task ExecuteNonQuery(string procName, params SqlParameter[] parameters)
    {
        using var conn = new SqlConnection(_connectionString);
        using var cmd = new SqlCommand(procName, conn);
        cmd.CommandType = CommandType.StoredProcedure;

        if (parameters != null)
            cmd.Parameters.AddRange(parameters);

        await conn.OpenAsync();
        await cmd.ExecuteNonQueryAsync();
    }

    
}

