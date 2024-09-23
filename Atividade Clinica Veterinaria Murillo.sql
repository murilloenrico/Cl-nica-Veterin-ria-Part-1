create schema clinicavet;
use clinicavet;

create table paciente(
id_paciente int auto_increment primary key,
nome  varchar (100),
especie varchar (50),
idade int);

insert into paciente (nome, especie, idade)
values ('Maya','Cachorro',1);

select * from paciente;


create table veterinario (
id_veterinario int auto_increment primary key,
nome varchar (100),
especialidade VARCHAR (50));

insert into veterinario (nome, especialidade)
values ('Thiago', 'Aves');

SELECT * FROM veterinario;


create table consultas (
id_consulta int auto_increment primary key,
id_pacientefk int,
id_veterinariofk int,
data_consulta date,
custo decimal (10,2),
constraint id_pacientefkk Foreign key (id_pacientefk) references paciente (id_paciente),
constraint id_veterinariofkk Foreign key (id_veterinariofk)  references veterinario (id_veterinario));

insert into consultas (id_pacientefk, id_veterinariofk, data_consulta, custo)
values (1,1,'2024-09-22', 110.90);

SELECT * FROM consultas;


DELIMITER //
CREATE PROCEDURE agendar_consulta (
    IN id_paciente INT,
    IN id_veterinario INT,
    IN data_consulta DATE,
    IN custo DECIMAL(10, 2)
)
BEGIN
    INSERT INTO consultas (id_pacientefk, id_veterinariofk, data_consulta, custo)
    VALUES (id_pacientefk, id_veterinariofk, data_consulta, custo);
    
    SELECT 'Consulta agendada com sucesso.' AS Mensagem;
END //
DELIMITER ;

CALL agendar_consulta(1, 1, '2024-09-30', 150.00);





DELIMITER //
CREATE PROCEDURE atualizar_paciente (
    IN id_paciente INT,
    IN novo_nome VARCHAR(100),
    IN nova_especie VARCHAR(50),
    IN nova_idade INT
)
BEGIN
    UPDATE paciente
    SET nome = novo_nome,
        especie = nova_especie,
        idade = nova_idade
    WHERE id_paciente = id_paciente;
    IF ROW_COUNT() > 0 THEN
        SELECT 'Paciente atualizado com sucesso.' AS Mensagem;
    ELSE
        SELECT 'Nenhum paciente encontrado com o ID fornecido.' AS Mensagem;
    END IF;
END //
DELIMITER ;
drop procedure atualizar_paciente;
call atualizar_paciente (1,'Golias','Macaco',12);




DELIMITER //
CREATE PROCEDURE remover_consulta (
    IN id_consulta INT
)
BEGIN
    DELETE FROM consultas
    WHERE id_consulta = id_consulta;
    IF ROW_COUNT() > 0 THEN
        SELECT 'Consulta removida com sucesso.' AS Mensagem;
    ELSE
        SELECT 'Nenhuma consulta encontrada com o ID fornecido.' AS Mensagem;
    END IF;
END //
DELIMITER ;
drop procedure remover_consulta;
CALL remover_consulta(1);





DELIMITER //
CREATE FUNCTION total_gasto_paciente (
 id_paciente INT
) 
RETURNS DECIMAL(10, 2)
BEGIN
    DECLARE total DECIMAL(10, 2);
    SELECT SUM(custo) INTO total
    FROM consultas
    WHERE id_pacientefk = id_paciente;
    RETURN IFNULL(total, 0.00);
END //
DELIMITER ;
SELECT total_gasto_paciente(1) AS total_gasto;




DELIMITER //
CREATE TRIGGER verificar_idade_paciente
BEFORE INSERT ON paciente
FOR EACH ROW
BEGIN
    IF NEW.idade < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Idade inválida: deve ser um número positivo.';
    END IF;
END //
DELIMITER ;

insert into paciente (nome, especie, idade)
VALUES ('Theo', 'passarinho', -5);





CREATE TABLE Log_Consultas (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_consulta INT,
    custo_antigo DECIMAL(10, 2),
    custo_novo DECIMAL(10, 2),
    data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE TRIGGER atualizar_custo_consulta
AFTER UPDATE ON consultas
FOR EACH ROW
BEGIN
    IF OLD.custo <> NEW.custo THEN
        INSERT INTO Log_Consultas (id_consulta, custo_antigo, custo_novo)
        VALUES (NEW.id_consulta, OLD.custo, NEW.custo);
    END IF;
END //
DELIMITER ;

UPDATE consultas SET Custo = 100.00 WHERE id_consulta = 1;