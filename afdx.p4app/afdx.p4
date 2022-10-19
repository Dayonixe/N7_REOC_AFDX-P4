#define AFDX_CST 0x03000000

header_type afdx_t {
	fields {
		cst: 32;
		VL_id: 16;
		src: 48;
		type: 16;
	}
}

header afdx_t afdx;

parser start {
       return parse_afdx_frame;
}

parser parse_afdx_frame {
	extract(afdx);
	return select(afdx.cst) {
		AFDX_CST: ingress;
	}
}

action forward_afdx(port) {
	modify_field(standard_metadata.egress_spec, port);
}

action _drop() {
	drop();
}

table forward_table {
	reads {
		afdx.VL_id: exact;
	}
	actions {
		forward_afdx;
		_drop;
	}
}

control ingress {
	apply(forward_table);
}

control egress {
	// ne pas modifier
}

       
