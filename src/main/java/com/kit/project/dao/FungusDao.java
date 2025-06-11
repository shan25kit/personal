package com.kit.project.dao;

import java.util.List;

import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import com.kit.project.dto.Fungus;

@Mapper
public interface FungusDao {

	@Insert("""
			<script>
			 INSERT INTO fungus (fngsPilbkNo, fngsGnrlNm)
			 VALUES
			 <foreach collection="list" item="item" separator=",">
			     (#{item.fngsPilbkNo}, #{item.fngsGnrlNm})
			 </foreach>
			 </script>
			""")
	public void postFngsdata(List<Fungus> dataList);

	@Select("""
			SELECT fngsPilbkNo, fngsGnrlNm
			FROM fungus
			WHERE id = #{id};
			""")
	public Fungus getFungusById(int id);
}
